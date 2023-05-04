# n3 law registry

contracts, sdk and cli

made with foundry

## how use sdk?

- import `@linkedpm/sdk`
- get an ethers provider or smth idk
- names are self explanatory + typescript typings but anyways
- all read/write functions have a config object at the end, you can put in a provider/signer and a custom contract if you like

### claimZone

calls the claimZone() function on the contract

### createRevision

creates a new revision of an agreement and throws if it exists (no real custom error handling).

if agreement also doesnt exist, then it'll make the agreement. note that revisions other than `latest` are immutable

the IPFS CID you point to should be a JSON file with the following format:

```json
{
  "name": "Revision name here, no Markdown",
  "description": "Revision description in Markdown, may include a changelog\nThat \\n makes a newline",
  "body": "Actual agreement text here written in Linked Markdown"
}
```

the linked markdown parser should fetch your agreements at runtime. it will only fetch ipfs cids and not https stuff because you can already point to a link for your metadata

### revisionData

gets the IPFS CID of the particular revision
