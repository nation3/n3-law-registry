// expect a local node being run on port 8545

import { ethers } from "ethers";
import { createRevision, claimZone } from "../src/index";
// spin up a foundry signer

let privkey =
  "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
let provider = new ethers.providers.StaticJsonRpcProvider(
  "http://localhost:8545"
);

let signer = new ethers.Wallet(privkey, provider);
it("should create a zone", () => {
  claimZone("hfsdfsj", { provider: signer });
});
