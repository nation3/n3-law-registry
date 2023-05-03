// expect a local node being run on port 8545

import { ethers } from "ethers";
import {
  createRevision,
  claimZone,
  zoneOwner,
  resolvePath,
  revisionData,
} from "../src/index";
// spin up a foundry signer

let privkey =
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
let provider = new ethers.providers.JsonRpcProvider("http://127.0.0.1:8545");

let signer = new ethers.Wallet(privkey, provider);

it("should create a zone", async () => {
  await claimZone("awesomezone", { signer });

  const owner = await zoneOwner("awesomezone", { provider });

  expect(owner).toEqual(signer.address);
});

it("should add an agreement", async () => {
  await claimZone("coolzone", { signer });
  await createRevision("coolzone", "mykey", "v69.333.0", "IPFS CID here", {
    signer,
  });
});

it("should add a new revision", async () => {
  await claimZone("sweetzone", { signer });
  await createRevision("sweetzone", "mykey", "v69.420.0", "IPFS CID here", {
    signer,
  });
  await createRevision("sweetzone", "mykey", "v69.420.1337", "IPFS CID here", {
    signer,
  });
});

it("should fail to rewrite a revision", async () => {
  await claimZone("nicezone", { signer });
  await createRevision(
    ...resolvePath("nicezone/rewritetestkey@v69.420.0"),
    "IPFS CID here",
    {
      signer,
    }
  );

  try {
    await createRevision(
      ...resolvePath("nicezone/rewritetestkey@v69.420.0"),
      "another IPFS CID here",
      {
        signer,
      }
    );
  } catch (e) {
    expect(e.toString()).toMatch("exists");
  }
});

it("should rewrite latest revision", async () => {
  await claimZone("amazingzone", { signer });

  const owner = await zoneOwner("amazingzone", { provider });
  expect(owner).toEqual(signer.address);

  await createRevision(...resolvePath("amazingzone/coolkey"), "IPFS CID here", {
    signer,
  });

  const cid = await revisionData(...resolvePath("amazingzone/coolkey"), {
    provider,
  });

  expect(cid).toBe("IPFS CID here");

  await createRevision(
    ...resolvePath("amazingzone/coolkey"),
    "IPFS CID here 2",
    {
      signer,
    }
  );

  const cid2 = await revisionData(...resolvePath("amazingzone/coolkey"), {
    provider,
  });

  expect(cid2).toBe("IPFS CID here 2");
});

it("should get revision data", async () => {
  await claimZone("greatzone", { signer });
  await createRevision(
    ...resolvePath("greatzone/coolkey@v1337"),
    "IPFS CID here",
    {
      signer,
    }
  );

  const cid = await revisionData(...resolvePath("greatzone/coolkey@v1337"), {
    provider,
  });

  expect(cid).toBe("IPFS CID here");
});
