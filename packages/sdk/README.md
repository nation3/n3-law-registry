# Linked.md Package Manager SDK

## what?

https://linked.md

## how use sdk?

- import `linkedpm`
- requires an ethers provider
- all read/write functions have a config object at the end, you can put in a provider/signer and a custom contract if you like

### claimZone

calls the claimZone() function on the contract.

usage example:

```ts
import sdk from "@linkedpm/sdk";

async function claimIt() {
  await sdk.claimZone("zone-name", {
    signer: new ethers.Wallet("private key", provider),
    // ^ or any other signer, not just a wallet
    contract: contractAddress,
    // you don't need to specify this, it should
    // autodetect based on the signer's blockchain
  });
}
```

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

the linked markdown parser should fetch your agreements at runtime. it should only fetch IPFS CIDs.

usage example:

```ts
import sdk from "@linkedpm/sdk";

async function create() {
  // publish your stuff to IPFS
  // this SDK is unopinionated
  let ipfsCID = ...

  // create the revision on-chain
  await sdk.createRevision("zone-name", "key-name", "latest", ipfsCID, {
    signer: new ethers.Wallet("private key", provider),
    // ^ or any other signer, not just a wallet
    contract: contractAddress,
    // you don't need to specify this, it should
    // autodetect based on the signer's blockchain
  });
}
```

### revisionData

gets the IPFS CID of the revision.

usage example:

```ts
import sdk from "@linkedpm/sdk";

async function check() {
  const data = await sdk.revisionData("zonename", "thing", "v69.420.0", {
    provider,
    contract: contractAddress,
    // you don't need to specify this, it should
    // autodetect based on the provider's blockchain
  });

  console.log(data);
}
```

### zoneOwner

gets the owner of a zone

usage example:

```ts
import sdk from "@linkedpm/sdk";

async function checkOwner() {
  const owner = await sdk.zoneOwner("zonename", {
    provider,
    contract: contractAddress,
    // you don't need to specify this, it should
    // autodetect based on the provider's blockchain
  });

  console.log(owner);
}
```

### resolvePath

a pure function that takes in a path, for example "zonename/thing@v69.420.0" and returns an array of "zonename", "thing", and "v69.420.0".

you can use the spread operator to pass these values easily to createRevision and revisionData

usage example:

```ts
import sdk, { resolvePath } from "@linkedpm/sdk";

async function check() {
  await sdk.revisionData(...resolvePath("zonename/thing@v69.420.0"), {
    provider,
    // provider can be unspecified
    contract: contractAddress,
    // you don't need to specify this, it should
    // autodetect based on the provider's blockchain
  });
}
```
