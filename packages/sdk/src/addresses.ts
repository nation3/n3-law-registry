import { a as addressFoundry } from "../../contracts/out/deploy-31337-latest.json";

const addresses = {
  "31337": { address: addressFoundry, type: "l1" },
  // "1": {address: "blahblahaddresshere", type: "l1"},
  "10": { address: "0x002b83f6166f467c430d2154bc30d46f6d5f501c", type: "l2" },
} as {
  [index: string]: { address: string; type: "l1" | "l2" };
};

export default addresses;
