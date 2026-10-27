---
title: My workflow using Matt Pocock's skills across multiple repositories
permalink: /matt-pocock-skills-workflow-across-multiple-repos
layout: post
date: 2026-10-27
category: post
---

This post explains (with examples) how I'm currently using [Matt Pocock's skills](https://www.aihero.dev/skills) (specifically `/grill-with-docs` and `/implement`) across multiple repositories. This can easily scale down to a single repository but I've found it useful for moderately complex features that span repositories.

With my current client I'm working across two different repositories, and many features are cross-repository; a feature might have front-end work in one repository and API and database work in another repository. I have Matt Pocock's skills installed globally and I'm using GitHub Copilot via VS Code. We've got tickets in Azure DevOps, and I'm writing specs locally (to the appropriate repo).

I'm using Copilot heavily with this project - we have a fixed timeline and a large number of features to be implemented. So my job becomes managing requirements, guiding the creation of detailed specs and implementation plans, and reviewing and testing the results. Because I can be speccing out features while Copilot is working on implementation, I need to manage my workflow carefully.

While for this project I'm using GitHub Copilot and VS Code, you could easily adapt this workflow to something like Claude Code in a terminal. The steps below don't rely on a particular toolset.

"Grilling" is a Pocock skill with smarts around domain modelling that researches and gathers information about a feature by conducting a grilling session - asking you a series of questions that clarify a feature. The `/grill-with-docs` skill writes any domain terms that it discovers to a glossary that can be referred to across grilling sessions.

If you're familiar with Pocock's skills, I'm using `/grill-with-docs` rather than the higher level `/wayfinder` because there is a healthy backlog of relatively well-specified and very granular tickets in Azure DevOps, so for this particular project I just want to build up then implement a spec against a pre-defined ticket.

These tickets were written by the product owner, and are basically a list of requirements that have enough detail to be able to understand what's needed, but not always enough to fully implement without some research and decision making. `/grill-with-docs` is perfect for this.

## File structure

To set up the skills, I ran `/setup-matt-pocock-skills` in each repo. The structure looks like this:

```
C:\development\
    |- northwind-backend\
    |   |- docs\
    |   |   |- specs\
    |   |- AGENTS.md
    |   |- glossary.md
    |- northwind-frontend\
    |   |- docs\
    |   |   |- specs\
    |   |- AGENTS.md
    |   |- glossary.md
```

From here I've got VS Code open from the `C:\development` directory. This lets the agents use the context of the entire system - all of the repositories have their own documentation but the agents can work across multiple repositories.

Note that each repository has its own `glossary.md` and `AGENTS.md`. Generally this works out ok - the agent writes to the appropriate glossary and uses the appropriate `AGENTS.md` file for the repository it's working in. There is some duplication but that's a trade-off with multiple related repositories.

Alternatively, you could have the supporting files at the top level - `C:\development`. This might make the specs harder to version control and share across the team, but it could reduce the duplication and make things clearer.

## Scratchpad, and ticket management

This is optional, but to manage my work I have a scratchpad document open in Obsidian. This is what I use for the starting template for each ticket. Note that I'm using `=>` to indicate a prompt - `=> /implement this feature` means to use `/implement this feature` as a prompt.

```markdown
- [ ] **Writing prompt** [Product Backlog Item 28661](https://dev.azure.com/link-to-ticket/28661) Submit feedback on a recent purchase
	- [ ] Prompt
	- [ ] Create spec
		- [ ] Start grilling session
		- [ ] Be grilled
		- [ ] Review spec
		- [ ] Commit spec
	- [ ] Implement
	    - [ ] => Create a detailed end-to-end implementation plan for spec `northwind-frontend/docs/specs/28661-submit-feedback-on-a-recent-purchase/spec.md` and write it as `implementation-plan.md` alongside the spec
	    - [ ] => /implement this feature end-to-end. Don't commit your changes. Remember YAGNI, keep code lean, optimise for readability and maintainability, and include comments where appropriate.
	    - [ ] Review code
	- [ ] Test
		- [ ] Run backend unit tests
		- [ ] Run frontend unit tests
		- [ ] Run frontend UI tests
		- [ ] Manually test in frontend
			- [ ] Steps - take from `manual-testing.md`
	- [ ] Backend PR
	- [ ] Frontend PR
	- [ ] Approved?
	- [ ] Merge backend PR
	- [ ] Merge frontend PR
	- [ ] Release backend to UAT
	- [ ] Release frontend to UAT
	- [ ] Smoke test in UAT
	- [ ] Comment and move ticket
```

These are the broad stages of a ticket in my workflow.

1. Writing the `/grill-with-docs` prompt
2. Grilling and reviewing the spec
3. Implementing and reviewing the code
4. Testing
5. Creating PRs, merging, releasing, completing the ticket

### Stage 1: Writing the `/grill-with-docs` prompt

The prompt is as detailed as reasonably possible, because it sets up the context for the grilling session and makes it faster to lock down requirements.

I have a template that I use for every ticket's prompt. Because this particular feature starts in the frontend, I've decided to write the spec to the frontend repo even though it will include supporting changes to the backend.

```markdown
=> /grill-with-docs Let's create a frontend spec. Customers should be able to provide feedback on a recent purchase.
We'll write the spec to `northwind-frontend/docs/specs/28661-submit-feedback-on-a-recent-purchase/spec.md`. Write manual testing steps alongside the spec in `manual-testing.md`. Write a high-level and non-technical summary of the decisions we have made for validation with the product owner to `decision-summary.md` alongside the spec, including a summarised list of individual decisions for the product owner to validate.
Note that this will require backend APIs to be created.
{detailed requirements here}
```

After that go the detailed requirements from the ticket, cleaned up to remove any ambiguity and to include details that can help the grilling session. It can also speed things up to include ticket numbers for associated tickets, especially if you're creating a specification for a feature that depends on work that has been previously specified but not yet implemented. Working too far ahead of what has actually been implemented can introduce ambiguity, so if you're noticing that the grilling session is asking background questions that are out of scope and covered by other tickets it might be a hint to cancel grilling for that ticket until after the prerequisite tickets have been implemented.

### Stage 2: Grilling and reviewing the spec

The grilling prompt from stage 1 goes straight into the agent chat. The context in the prompt basically pre-loads the session so that decisions that have already been made in the ticket are understood immediately by the agent.

I use a more capable model to conduct the grilling session - a top or middle-top level model, with medium effort. Higher effort might give better results if there is more ambiguity but I've found that even with plenty of context and reference code it can still get into 100+ question sessions, spinning on trivial decisions. Medium effort gives good results over 20 to 50 questions for a well specified ticket.

The grilling session involves the agent exploring the system, including previous specs, then asking questions. It usually asks ten questions at a time. I find it helps to open another text editor to write down the answers, rather than entering them directly into the chat.

Make sure you read and understand each question before answering. While most of the answers may be simply "agreed", this step is where we have the most direct influence on what will be built. 

It's important to identify and clarify interpretations that are incorrect or that don't capture something that was unclear in the requirements.

If you're not sure about the answer to a question you can ask for clarification or more information. The grilling session will let you guide it while keeping you on track.

#### Reviewing the outputs

The result of the grilling session should be three files for you to review, plus edits to `glossary.md`.

**`spec.md`**:
The actual specification. This should include research and the proposed solution. It doesn't need to go deep into implementation details as we'll create a detailed end-to-end implementation plan in the next stage. Carefully review this to make sure the spec covers the requirements and doesn't include anything that should be out of scope.

**`decision-summary.md`**:
A summary of the decisions that were made for review by the product owner. You should use this document to extract interesting or possibly controversial decisions and run them past the product owner to get agreement on the proposed solution.

**`manual-testing.md`**:
Manual testing steps. Review this document to make sure the steps are comprehensive and can actually be performed. I like to copy the steps into the scratchpad so I can mark them as complete when manually testing the implemented feature.

### Stage 3: Implementing and reviewing the code

This doesn't need to happen in the same session as the grilling, as the outputs of that session should have enough detail for another session to pick up and implement. This lets me run grilling sessions and generate specs in advance, so I can keep working while another session is implementing a feature. I would continue to use a more capable model for the first step of this stage - creating the implementation plan.

```markdown
Create a detailed end-to-end implementation plan for spec `northwind-frontend/docs/specs/28661-submit-feedback-on-a-recent-purchase/spec.md` and write it as `implementation-plan.md` alongside the spec
```

Note that since the feature is cross-repository, the implementation plan should include proposed changes to both the frontend and the backend repositories.

Review the implementation plan very carefully, looking for gaps and things that are overbaked. For example, while idempotency is a good goal, if you're creating an intranet web app that is used by a small number of users it might not be required and will make code more complex without adding enough value. Make sure you understand how the feature is going to be implemented.

Once you're happy with the plan, kick off the actual implementation. For this I generally switch to a medium capability model, since we're providing the detailed implementation plan. I do like to keep this in the same session as the creation of the implementation plan, as I have a feeling that some of the context from the research when creating the plan could help the agent during implementation.

```markdown
/implement this feature end-to-end. Don't commit your changes. Remember YAGNI, keep code lean, optimise for readability and maintainability, and include comments where appropriate.
```

I tell the agent not to commit changes because committing changes is the `/implement` skill's default, but I want to review, tweak, and stage code for a commit myself; I find it gives me more control over what I'm committing.

This step can take some time. I've become used to a moderately complex feature taking around 30-40 minutes to be implemented. The nice part of using Pocock's `/implement` skill is that it will use TDD and run code reviews out of the box, and the guardrails we've established by grilling to produce the spec and having comprehensive implementation steps mean that we can have a level of trust in the work the agent is performing.

When implementation is complete, start manually reviewing the code. Look for parts that you don't understand or that feel overbaked, and use the agent to make corrections or explain why it did something in a particular way. Remember that it's basically one-shotting an entire implementation and you can sometimes end up with thousands of lines of code to review for moderately complex features. Treat the code review as you would for a PR review from a colleague, and if you've got non-trivial feedback make use of the agent session.

### Stage 4: Testing

Having offloaded a lot of the research, specification, and implementation tasks, this is where you can pay back some of the time saved by performing in-depth testing.

Before I started using AI tooling in my standard development practice, I would test as I was developing. Having the feature implemented in one shot means that you need to test edge cases and non-happy paths more comprehensively. Make sure you follow the manual testing steps that were generated in stage 2.

I cannot overstate how important this testing step becomes with spec-driven AI assisted development. Although we've offloaded a lot of the manual development work, as software developers we're still responsible for the result of the work, whether we wrote it ourselves or delegated it to an agent. 

*Software quality is more important than ever*.

### Stage 5: Creating PRs, merging, releasing, completing the ticket

The remaining steps for a ticket are straightforward and don't use AI. I include them in my scratchpad so I can better manage the external workflow for each ticket while I'm multitasking.

## Multitasking

I find that using a scratchpad can help with keeping my mental work-in-progress small, letting me keep working while agents are off implementing a feature. After all, [human multitasking](https://en.wikipedia.org/wiki/Human_multitasking) is largely a myth.

I like to start implementation, and while that's happening, write a prompt and open another chat to start grilling. This does require context switching, but grilling helpfully asks ten or so questions at a time, so I can concentrate on answering those questions and sending the grilling session off doing more research while I'm reviewing code.

Or I take a break to make a coffee. I find this way of working very effective, and with sufficient guardrails and manual checks the quality is high, and I enjoy it a lot more than manually writing code these days. But the multitasking and orchestrating can be mentally intensive, so I try to take short breaks when possible, to reset. Using the scratchpad to manage where I'm at with each ticket helps with locking back in to what I'm currently working on.

## Fin

Using this workflow lets me take advantage of domain modelling skills that guide the development of a spec and the implementation of the final feature. It means that we can take somewhat ambiguous requirements and develop detailed documentation that acts as guardrails for implementation.

The automated implementation of the feature buys us time to work on defining the spec and perform testing and validation. I find that spec-driven development with AI agents researching and implementing doesn't necessarily translate into faster delivery of features, but it does result in higher quality outcomes that can comprehensively cover edge cases and error conditions.

In my mind, spec-driven development is the evolution of vibe coding. It sets up guardrails that allow us to:

- Trust our tooling,
- Avoid poorly written, expensive to maintain code, and
- Keep the human in the loop (that's you!)
