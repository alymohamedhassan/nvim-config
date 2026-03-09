---
name: docx-editing
description: Create and edit Microsoft Word (.docx) files using the Word Document MCP. Use when the user wants to create a new docx, edit an existing docx, add headings/paragraphs/tables/images, format text, search-and-replace, or extract content from Word documents.
---

# Docx Editing (Word Documents)

When the user asks to create or edit `.docx` files, use the **word-document** MCP server tools. Paths to documents can be absolute or relative to the current workspace; prefer absolute paths when the user points to a specific file.

## When to Use This Skill

- User says they want to create a Word document, report, or letter
- User wants to edit an existing .docx (add/change text, headings, tables, formatting)
- User asks to extract text, outline, or comments from a docx
- User mentions docx, Word document, or .docx files

## Quick Workflow

1. **Create new document**: Use `create_document` with filename (e.g. `report.docx`), optional title/author.
2. **Add content**: Use `add_heading`, `add_paragraph`, `add_table`, `add_picture`, `add_page_break`, or list tools (`insert_numbered_list_near_text` with `bullet_type`: `bullet` or `number`).
3. **Edit existing**: Use `get_document_text` or `get_document_outline` to inspect, then `format_text`, `search_and_replace`, `insert_line_or_paragraph_near_text`, or `delete_paragraph` as needed.
4. **Tables**: Create with `add_table`; format with `format_table`, `set_table_cell_shading`, `format_table_cell_text`, `merge_table_cells_*`, `set_table_column_width`, etc.
5. **Extract**: Use `get_document_text`, `get_document_outline`, `get_all_comments`, or `get_document_info` as needed.

## Important Conventions

- **File paths**: Pass full path to the docx (e.g. `/Users/aly/Documents/report.docx` or workspace-relative path). The MCP operates on files on disk.
- **Indices**: Paragraph and table indices are **0-based**. Use `get_document_text` or `get_document_outline` to find indices before editing.
- **Colors**: Use hex without `#` (e.g. `FF0000` for red) or standard color names.
- **Insert near text**: Use `insert_header_near_text`, `insert_line_or_paragraph_near_text`, or `insert_numbered_list_near_text` with `target_text` or `target_paragraph_index` and `position` (`before`/`after`).

## Common Operations

| Goal | Tool(s) |
|------|--------|
| New docx | `create_document` |
| Add title/heading | `add_heading` (level 1–n) |
| Add body text | `add_paragraph` |
| Bold/italic/color on a span | `format_text` (paragraph_index, start_pos, end_pos) |
| Replace all "X" with "Y" | `search_and_replace` |
| Table | `add_table` then `format_table` / `format_table_cell_text` / etc. |
| List after a paragraph | `insert_numbered_list_near_text` (position=`after`, bullet_type=`bullet` or `number`) |
| See structure | `get_document_outline`, `get_document_text` |
| Comments | `get_all_comments`, `get_comments_by_author`, `get_comments_for_paragraph` |

## Optional Capabilities

- **Merge docs**: `merge_documents` (see MCP tool list).
- **Convert to PDF**: `convert_to_pdf`.
- **Protection**: `add_password_protection`, `add_restricted_editing` (see MCP tools).
- **Copy before editing**: Use `copy_document` if the user wants to keep an original.

Always confirm the target file path with the user when creating a new document or overwriting an existing one.
