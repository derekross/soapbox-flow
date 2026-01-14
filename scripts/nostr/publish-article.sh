#!/bin/bash

# Publish a Derek Ross blog post from soapbox.pub to Nostr as a NIP-23 long-form article
#
# Usage: ./publish-derek-ross-article.sh <slug> [--local]
# Example: ./publish-derek-ross-article.sh shakespeare-mobile-development
#          ./publish-derek-ross-article.sh shakespeare-mobile-development --local
#
# The script will:
# 1. Fetch the blog post from soapbox.pub (or localhost with --local)
# 2. Extract metadata and convert HTML content to markdown
# 3. Prompt for your nsec and publish to Nostr relays

set -e

# Configuration
PROD_URL="https://soapbox.pub"
LOCAL_URL="http://localhost:8082"
BASE_URL="$PROD_URL"

# Default relays
RELAYS=(
    "wss://relay.primal.net"
    "wss://relay.damus.io"
    "wss://relay.ditto.pub"
    "wss://nos.lol"
    "wss://relay.snort.social"
    "wss://nostr-relay.derekross.me"
)

# Parse arguments
SLUG=""
for arg in "$@"; do
    case $arg in
        --local)
            BASE_URL="$LOCAL_URL"
            ;;
        *)
            SLUG="$arg"
            ;;
    esac
done

if [ -z "$SLUG" ]; then
    echo "Usage: $0 <blog-slug-or-url> [--local]"
    echo ""
    echo "Options:"
    echo "  --local    Fetch from localhost:8082 instead of soapbox.pub"
    echo ""
    echo "Examples:"
    echo "  $0 shakespeare-mobile-development"
    echo "  $0 https://soapbox.pub/blog/shakespeare-mobile-development"
    echo "  $0 announcing-shakespeare-community --local"
    exit 1
fi

# Handle full URL or just slug
if [[ "$SLUG" =~ ^https?:// ]]; then
    # Full URL provided - extract the slug from it
    BLOG_URL="$SLUG"
    SLUG=$(echo "$SLUG" | sed 's|.*/blog/||')
else
    # Just a slug provided - construct the URL
    BLOG_URL="${BASE_URL}/blog/${SLUG}"
fi

echo "Fetching: $BLOG_URL"
echo ""

# Create temporary files
TEMP_DIR=$(mktemp -d)
HTML_FILE="$TEMP_DIR/page.html"
MD_FILE="$TEMP_DIR/article.md"
trap "rm -rf $TEMP_DIR" EXIT

# Fetch the blog page
if ! curl -sL "$BLOG_URL" -o "$HTML_FILE"; then
    echo "Error: Failed to fetch $BLOG_URL"
    exit 1
fi

# Check if page was found (look for 404 or empty content)
if grep -q "NotFound\|Page not found\|404" "$HTML_FILE" 2>/dev/null; then
    echo "Error: Blog post not found at $BLOG_URL"
    exit 1
fi

# Extract metadata and convert to markdown using Python
METADATA_FILE="$TEMP_DIR/metadata.json"

HTML_FILE="$HTML_FILE" MD_FILE="$MD_FILE" METADATA_FILE="$METADATA_FILE" BASE_URL="$BASE_URL" SLUG="$SLUG" python3 << 'PYEOF'
import os
import re
import json
from html.parser import HTMLParser

html_file = os.environ['HTML_FILE']
md_file = os.environ['MD_FILE']
metadata_file = os.environ['METADATA_FILE']
base_url = os.environ.get('BASE_URL', 'https://soapbox.pub')

with open(html_file, 'r') as f:
    html = f.read()

# Extract metadata from meta tags and JSON-LD
metadata = {}

# Title from og:title or title tag
title_match = re.search(r'<meta[^>]*property="og:title"[^>]*content="([^"]*)"', html)
if title_match:
    # Remove " - Soapbox Blog" or similar suffixes
    metadata['title'] = re.sub(r'\s*-\s*Soapbox.*$', '', title_match.group(1)).strip()
else:
    title_match = re.search(r'<title>([^<]*)</title>', html)
    if title_match:
        metadata['title'] = title_match.group(1).split(' - ')[0].strip()

# Description/excerpt
desc_match = re.search(r'<meta[^>]*property="og:description"[^>]*content="([^"]*)"', html)
if not desc_match:
    desc_match = re.search(r'<meta[^>]*name="description"[^>]*content="([^"]*)"', html)
if desc_match:
    metadata['excerpt'] = desc_match.group(1)

# Image
img_match = re.search(r'<meta[^>]*property="og:image"[^>]*content="([^"]*)"', html)
if img_match:
    metadata['image'] = img_match.group(1)

# Published date from article:published_time or JSON-LD
date_match = re.search(r'<meta[^>]*property="article:published_time"[^>]*content="([^"]*)"', html)
if date_match:
    metadata['date'] = date_match.group(1)[:10]  # Just the date part

# Author
author_match = re.search(r'"author"[^}]*"name"\s*:\s*"([^"]*)"', html)
if author_match:
    metadata['author'] = author_match.group(1)

# Try to find date from the page content (time tag)
if 'date' not in metadata:
    time_match = re.search(r'<time[^>]*datetime="([^"]*)"', html)
    if time_match:
        metadata['date'] = time_match.group(1)[:10]

# Extract the article content
article_match = re.search(r'<article[^>]*class="[^"]*prose[^"]*"[^>]*>(.*?)</article>', html, re.DOTALL)
if not article_match:
    article_match = re.search(r'<article[^>]*>(.*?)</article>', html, re.DOTALL)
if not article_match:
    # Try to find main content area
    article_match = re.search(r'<div[^>]*class="[^"]*prose[^"]*"[^>]*>(.*?)</div>\s*</div>\s*</article>', html, re.DOTALL)

if article_match:
    content = article_match.group(1)
else:
    # Fallback: get body content
    content = re.sub(r'^.*?<body[^>]*>', '', html, flags=re.DOTALL)
    content = re.sub(r'</body>.*$', '', content, flags=re.DOTALL)

# Convert HTML to Markdown

# Remove script and style tags
content = re.sub(r'<script[^>]*>.*?</script>', '', content, flags=re.DOTALL)
content = re.sub(r'<style[^>]*>.*?</style>', '', content, flags=re.DOTALL)

# Remove navigation elements, headers, footers
content = re.sub(r'<nav[^>]*>.*?</nav>', '', content, flags=re.DOTALL)
content = re.sub(r'<header[^>]*>.*?</header>', '', content, flags=re.DOTALL)
content = re.sub(r'<footer[^>]*>.*?</footer>', '', content, flags=re.DOTALL)

# Remove buttons and form elements
content = re.sub(r'<button[^>]*>.*?</button>', '', content, flags=re.DOTALL)
content = re.sub(r'<form[^>]*>.*?</form>', '', content, flags=re.DOTALL)
content = re.sub(r'<input[^>]*/?>', '', content)

# Remove SVG icons
content = re.sub(r'<svg[^>]*>.*?</svg>', '', content, flags=re.DOTALL)

# Convert headings
content = re.sub(r'<h1[^>]*>(.*?)</h1>', r'\n# \1\n', content, flags=re.DOTALL)
content = re.sub(r'<h2[^>]*>(.*?)</h2>', r'\n## \1\n', content, flags=re.DOTALL)
content = re.sub(r'<h3[^>]*>(.*?)</h3>', r'\n### \1\n', content, flags=re.DOTALL)
content = re.sub(r'<h4[^>]*>(.*?)</h4>', r'\n#### \1\n', content, flags=re.DOTALL)

# Convert blockquotes
content = re.sub(r'<blockquote[^>]*>(.*?)</blockquote>',
                 lambda m: '\n> ' + re.sub(r'\s+', ' ', m.group(1)).strip() + '\n',
                 content, flags=re.DOTALL)

# Convert links
content = re.sub(r'<a[^>]*href="([^"]*)"[^>]*>(.*?)</a>', r'[\2](\1)', content, flags=re.DOTALL)

# Convert images - make paths absolute
def fix_image(m):
    src = m.group(1)
    alt = m.group(2) if m.lastindex >= 2 else ''
    if src.startswith('/'):
        src = base_url + src
    return f'\n![{alt}]({src})\n'

content = re.sub(r'<img[^>]*src="([^"]*)"[^>]*alt="([^"]*)"[^>]*/?>', fix_image, content, flags=re.DOTALL)
content = re.sub(r'<img[^>]*alt="([^"]*)"[^>]*src="([^"]*)"[^>]*/?>',
                 lambda m: fix_image(type('obj', (object,), {'group': lambda s, i: m.group(2) if i == 1 else m.group(1), 'lastindex': 2})()),
                 content, flags=re.DOTALL)
content = re.sub(r'<img[^>]*src="([^"]*)"[^>]*/?>', lambda m: fix_image(m), content, flags=re.DOTALL)

# Convert bold/strong
content = re.sub(r'<strong[^>]*>(.*?)</strong>', r'**\1**', content, flags=re.DOTALL)
content = re.sub(r'<b[^>]*>(.*?)</b>', r'**\1**', content, flags=re.DOTALL)

# Convert italic/em
content = re.sub(r'<em[^>]*>(.*?)</em>', r'*\1*', content, flags=re.DOTALL)
content = re.sub(r'<i[^>]*>(.*?)</i>', r'*\1*', content, flags=re.DOTALL)

# Convert code
content = re.sub(r'<code[^>]*>(.*?)</code>', r'`\1`', content, flags=re.DOTALL)
content = re.sub(r'<pre[^>]*>(.*?)</pre>', r'\n```\n\1\n```\n', content, flags=re.DOTALL)

# Convert lists
content = re.sub(r'<ul[^>]*>', '\n', content)
content = re.sub(r'</ul>', '\n', content)
content = re.sub(r'<ol[^>]*>', '\n', content)
content = re.sub(r'</ol>', '\n', content)
content = re.sub(r'<li[^>]*>(.*?)</li>', r'- \1\n', content, flags=re.DOTALL)

# Convert paragraphs
content = re.sub(r'<p[^>]*>(.*?)</p>', r'\n\1\n', content, flags=re.DOTALL)

# Convert line breaks
content = re.sub(r'<br\s*/?>', '\n', content)

# Remove divs and spans but keep content
content = re.sub(r'<div[^>]*>', '\n', content)
content = re.sub(r'</div>', '\n', content)
content = re.sub(r'<span[^>]*>(.*?)</span>', r'\1', content, flags=re.DOTALL)
content = re.sub(r'<time[^>]*>(.*?)</time>', r'\1', content, flags=re.DOTALL)

# Remove any remaining HTML tags
content = re.sub(r'<[^>]+/?>', '', content)
content = re.sub(r'</[^>]+>', '', content)

# Decode HTML entities
content = content.replace('&amp;', '&')
content = content.replace('&lt;', '<')
content = content.replace('&gt;', '>')
content = content.replace('&quot;', '"')
content = content.replace('&#39;', "'")
content = content.replace('&nbsp;', ' ')

# Clean up whitespace
content = re.sub(r'\n{3,}', '\n\n', content)
content = re.sub(r'[ \t]+', ' ', content)
content = re.sub(r'\n +', '\n', content)
content = re.sub(r' +\n', '\n', content)
content = content.strip()

# Add cover image at the top if we have one
if metadata.get('image'):
    img_url = metadata['image']
    if img_url.startswith('/'):
        img_url = base_url + img_url
    content = f"![Cover]({img_url})\n\n" + content

# Add footer with original publication link
slug = os.environ.get('SLUG', '')
original_url = f"{base_url}/blog/{slug}" if slug else base_url
content += f"\n\n---\n\n*This article was originally published on [soapbox.pub]({original_url}).*"

with open(md_file, 'w') as f:
    f.write(content)

with open(metadata_file, 'w') as f:
    json.dump(metadata, f)
PYEOF

# Read metadata
if [ ! -f "$METADATA_FILE" ]; then
    echo "Error: Failed to extract metadata"
    exit 1
fi

TITLE=$(jq -r '.title // empty' "$METADATA_FILE")
EXCERPT=$(jq -r '.excerpt // empty' "$METADATA_FILE")
DATE=$(jq -r '.date // empty' "$METADATA_FILE")
IMAGE=$(jq -r '.image // empty' "$METADATA_FILE")
AUTHOR=$(jq -r '.author // empty' "$METADATA_FILE")

# Convert date to unix timestamp
DATE_UNIX=""
if [ -n "$DATE" ]; then
    DATE_UNIX=$(date -d "$DATE" +%s 2>/dev/null || echo "")
fi

echo "=== Article Metadata ==="
echo "Title: $TITLE"
echo "Author: $AUTHOR"
echo "Date: $DATE${DATE_UNIX:+ (unix: $DATE_UNIX)}"
echo "Excerpt: $EXCERPT"
echo "Image: $IMAGE"
echo ""

# Show preview
echo "=== Markdown Preview (first 50 lines) ==="
head -50 "$MD_FILE"
echo ""
echo "... (truncated)"
echo ""
echo "Full article: $(wc -l < "$MD_FILE") lines, $(wc -c < "$MD_FILE") bytes"
echo ""

# Build nak command
echo "=== Publishing to Nostr ==="
echo "Relays: ${RELAYS[*]}"
echo ""

# Build tag arguments
TAG_ARGS=()
[ -n "$TITLE" ] && TAG_ARGS+=(-t "title=$TITLE")
[ -n "$EXCERPT" ] && TAG_ARGS+=(-t "summary=$EXCERPT")
[ -n "$DATE_UNIX" ] && TAG_ARGS+=(-t "published_at=$DATE_UNIX")
if [ -n "$IMAGE" ]; then
    if [[ "$IMAGE" == /* ]]; then
        TAG_ARGS+=(-t "image=${PROD_URL}${IMAGE}")
    else
        TAG_ARGS+=(-t "image=$IMAGE")
    fi
fi

# Confirm before publishing
read -p "Publish this article to Nostr? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    echo ""
    echo "Markdown saved to: $MD_FILE"
    cp "$MD_FILE" "/tmp/article-${SLUG}.md"
    echo "Copied to: /tmp/article-${SLUG}.md"
    echo ""
    echo "You can manually publish with:"
    echo ""
    echo "nak event --prompt-sec -k 30023 -d \"$SLUG\" \\"
    for arg in "${TAG_ARGS[@]}"; do
        echo "  $arg \\"
    done
    echo "  -c @\"/tmp/article-${SLUG}.md\" \\"
    echo "  ${RELAYS[*]}"
    trap - EXIT
    exit 0
fi

# Publish with nak
echo "Publishing..."
nak event \
    --prompt-sec \
    -k 30023 \
    ${DATE_UNIX:+--ts "$DATE_UNIX"} \
    -d "$SLUG" \
    "${TAG_ARGS[@]}" \
    -c "@$MD_FILE" \
    "${RELAYS[@]}"

echo ""
echo "Done! Article published to Nostr."
