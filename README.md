# CONTRACTS-SOL

Solidity-based libraries for supporting ERC-721 and ERC-1155 smart contracts

Currently the feature-set is kept small to ensure that your contract size remains under the 24kb contract size limit. Also expect that the API may change before the 1.0.0 release.

Available as a package. Add it to `package.json`:

```
"@theappstudiollc/contracts": "0.9.0"
```

and import it in solidity:

```
import "@theappstudiollc/contracts/utils/OnChain.sol";
import "@theappstudiollc/contracts/utils/SVG.sol";
```
