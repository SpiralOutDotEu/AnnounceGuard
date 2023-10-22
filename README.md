# AnnounceGuard
## A blockchain guarded announcement system

## Usage
### Contracts

```sh
cd contracts
# Test
forge test
# Deploy
forge create --rpc-url <your_rpc_url> \
    --interactive \
    --verifier-url <your_verifier_url> \
    --etherscan-api-key  <your_verifier_api_key>\
    --verify \
    src/AnnouncementHub.sol:AnnouncementHub
```

### Deployment addresses
| Network | Contract Address                           |
| ------- | ------------------------------------------ |
| Mumbai  | 0x8D4459884f29d0488466A8c01B8363915184071c |

### Frontend
```
cd frontend
yarn dev
```

