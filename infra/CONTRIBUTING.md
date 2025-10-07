# Contributing to Infrastructure_AzureLocal_MAL

## Code of Conduct

* Be a good citizen.
* Be professional. We love meme's as much as the next guy/gal but your interactions will be visible to everyone.
* Please be kind and courteous. There's no need to be mean or rude.
* Be diligent and provide as much detail and context as possible.
* Respect that people have differences of opinion and that every design or implementation choice carries a trade-off and numerous costs. There is seldom a right answer.
* Please keep unstructured critique to a minimum. If you have solid ideas you want to experiment with, make a branch and see how it works.
* Avoid the use of personal pronouns in code comments or documentation. There is no need to address persons when explaining code (e.g. "When the developer").

## Issue Contributions

If you found an issue or want to request a feature/enhancement but don't have the time to work on it yourself please create an issue with as much detail as possible.

## Code Contributions

All code that is submitted must conform to the current style of the project.

### Merge Requests

Unlike GitHub we prefer that changes be made on a branch within the existing repo and NOT on a fork.
For more information on why we prefer this method please see the Inner Source page on [Merge Requests - Branching vs. Forks](link to documentation).

#### Step 1: Cloning

To get started first clone the repo to check it out locally.

    git clone URL to repository

#### Step 2: Branching

A new branch will need to be created in order to submit a merge request. Naming is not strict but the preference is to follow the [GitFlow](link to documentation) naming convention.

Create a branch and start making changes:

    git checkout -b feature/my-branch -t origin/master

#### Step 3: Commit

Make your changes, add and commit

    git add my/changed/files
    git commit

Writing good commit messages is critical. For a detailed guide on good commit messages please read  the following page on [good commits](linik to documentation)

#### Step 4: Push

Now that you are complete with you changes it's time to push the changes to the repo and create a merge request from ```<my-branch>``` to ```master``` or```main```.

**Please Note**: All updates to your branch will automatically update the Merge Request. There is no need to close and open a new one.

#### Step 5: Discuss and Update

You will probably get feedback or requests for changes to your Merge Request. This is a big part of the submission process so don't be disheartened!

To make changes to an existing Merge Request, make the changes to your branch. When you push that branch to the repo it will automatically update the Merge Request.

You can push more commits to your branch:

    git add my/changed/files
    git commit
    git push origin my-branch

Feel free to post a comment in the Merge Request to ping reviewers if you are awaiting an answer on something.

#### Step 6: Expectations on Reviews

We are all very busy so please be patient and allow approvers some time to review your changes and give comments. It will be unlikely that merge requests will be completed in a single day.

## Do's and Don'ts

* **DO** give priority to the current style of the project or file you're changing even if it diverges from the general guidelines.
* **DO** submit all code changes via merge requests (MRs) rather than through a direct commit. Merge request will be reviewed and potentially merged by the repo maintainers after a peer review that includes at least one maintainer.
* **DO** give merge requests short-but-descriptive names (e.g. "Improve code coverage for Compenent.X by 10%", not "Fix #1234")
* **DO** tag any users that should know about and/or review the change.
* **DO** ensure each commit successfully builds.
* **DO** address merge request feedback in an additional commit(s) rather than amending the existing commits, and only rebase/squash them when necessary.  This makes it easier for reviewers to track changes. If necessary, squashing should be handled by the merger using the ["squash and merge"](https://github.com/blog/2141-squash-your-commits) feature, and should only be done by the contributor upon request.
* **DO NOT** submit "work in progress" merge requests.  A merge request should only be submitted when it is considered ready for review and subsequent merging by the contributor.
* **DO NOT** send merge requests for style changes. For example, do not send merge requests that are focused on changing usage of ```Int32``` to ```int```.
* **DO NOT** send merge requests for updating a code to newer language features, though it's ok to use newer language features as part of new code that's written. For example, it's ok to use expression-bodied members as part of new code you write, but do not send a merge request focused on changing existing properties or methods to use the feature.
