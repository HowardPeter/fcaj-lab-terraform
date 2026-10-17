---
name: read-lab
description: Read a lab's docs URL, write README.md for the lab folder, and list the Terraform resources needed. No code changes. Use via /read-lab <lab-path> <docs-url>.
argument-hint: <lab-path> <docs-url>
disable-model-invocation: true
allowed-tools: Read, Glob, Grep, WebFetch, Write
---

Lab path: `$0`. Docs URL: `$1`. If either is missing, ask for it.

**Rules:** Only write `$0/README.md`, and change no other code. Never fetch `$1/vi/*`.  

1. **Understand the lab**
Fetch `$1` and every sub-page under it, except `$1/vi/*`, following nested links and fetching each page once.
Note the goal, architecture, services, prerequisites, steps, verification and clean-up.
Track the URLs you have already visited so you never fetch the same page twice.

2. **Write README**
Based on what you learned in Step 1. Follow the structure, headings and style of `./ec2-auto-scaling/README.md`.
Write the content for this lab to `$0/README.md`.

3. **List Terraform resources**
In the chat, list every Terraform resource and data source the lab needs.
Leave out Python, the AWS CLI and console steps. You can mention those briefly at the end as "out of scope", but do not count them.
Use this table, with the total count at the end:

   | # | Resource | Purpose | Lab step |
   |---|----------|---------|----------|

**Finish**
Reply with one line confirming the README was written, the Terraform resource table, and a note that no code was changed.