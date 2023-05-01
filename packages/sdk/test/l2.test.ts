// expect a local node being run on port 8545

import { ethers } from "ethers";
import {
  createRevision,
  claimZone,
  zoneOwner,
  revisionData,
} from "../src/index";
// spin up a foundry signer

let privkey =
  "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d";
let provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");

let signer = new ethers.Wallet(privkey, provider);

import { a as l2Address } from "../../contracts/out/deploy-l2-31337-latest.json";

it("should create a zone", async () => {
  await claimZone("awesomezone", { signer, contract: l2Address });

  const owner = await zoneOwner("awesomezone", {
    provider,
    contract: l2Address,
  });

  expect(owner).toEqual(signer.address);
});

it("should add an agreement", async () => {
  await claimZone("coolzone", { signer, contract: l2Address });
  await createRevision("coolzone", "mykey", "v69.333.0", "IPFS CID here", {
    signer,
    contract: l2Address,
  });
});

it("should add a new revision", async () => {
  await claimZone("sweetzone", { signer, contract: l2Address });
  await createRevision("sweetzone", "mykey", "v69.420.0", "IPFS CID here", {
    signer,
    contract: l2Address,
  });
});

it("should fail to rewrite a revision", async () => {
  await claimZone("nicezone", { signer, contract: l2Address });
  await createRevision(
    "nicezone",
    "rewritetestkey",
    "v69.420.0",
    "IPFS CID here",
    {
      signer,
      contract: l2Address,
    }
  );

  try {
    await createRevision(
      "nicezone",
      "rewritetestkey",
      "v69.420.0",
      "another IPFS CID here",
      {
        signer,
        contract: l2Address,
      }
    );
  } catch (e) {
    expect(e.toString()).toMatch("exists");
  }
});

it("should rewrite latest revision", async () => {
  await claimZone("amazingzone", { signer, contract: l2Address });

  const owner = await zoneOwner("awesomezone", {
    provider,
    contract: l2Address,
  });
  expect(owner).toEqual(signer.address);

  await createRevision("amazingzone", "coolkey", "latest", "IPFS CID here", {
    signer,
    contract: l2Address,
  });

  const cid = await revisionData("amazingzone", "coolkey", "latest", {
    provider,
    contract: l2Address,
  });

  expect(cid).toBe("IPFS CID here");

  await createRevision("amazingzone", "coolkey", "latest", "IPFS CID here 2", {
    signer,
    contract: l2Address,
  });

  const cid2 = await revisionData("amazingzone", "coolkey", "latest", {
    provider,
    contract: l2Address,
  });

  expect(cid2).toBe("IPFS CID here 2");
});

it("should get revision data", async () => {
  await claimZone("greatzone", { signer, contract: l2Address });
  await createRevision("greatzone", "coolkey", "v1337", "IPFS CID here", {
    signer,
    contract: l2Address,
  });

  const cid = await revisionData("greatzone", "coolkey", "v1337", {
    provider,
    contract: l2Address,
  });

  expect(cid).toBe("IPFS CID here");
});
