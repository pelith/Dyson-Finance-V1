#!/bin/sh

read -p "Please enter Solidity compile version:" solc_version
read -p "Please enter Solidity optimizer runs:" optimizer_runs
read -p "Please enter deploy rpc url:" rpc_url
echo "Please select target script:"
echo "1: MainnetDeploy"
echo "2: MainnetDeployPart1"
echo "3: MainnetDeployPart2"
echo "4: TreasuryVesterDeploy"
echo "5: DysonToGoFactoryDeploy"
echo "6: DysonToGoDeploy"
read -p "Please enter target script:" target_script_id
read -p "Is broadcast? (y/n):" is_broadcast

if [ "$target_script_id" = "1" ]; then
    target_script="src/script/MainnetDeploy.s.sol:MainnetDeployScript"
elif [ "$target_script_id" = "2" ]; then
    target_script="src/script/MainnetDeployPart1.s.sol:MainnetDeployScriptPart1"
elif [ "$target_script_id" = "3" ]; then
    target_script="src/script/MainnetDeployPart2.s.sol:MainnetDeployScriptPart2"
elif [ "$target_script_id" = "4" ]; then
    target_script="src/script/TreasuryVesterDeploy.s.sol:TreasuryVesterDeployScript"
elif [ "$target_script_id" = "5" ]; then
    target_script="src/script/DysonToGoFactoryDeploy.s.sol:DysonToGoFactoryDeployScript"
elif [ "$target_script_id" = "6" ]; then
    target_script="src/script/DysonToGoDeploy.s.sol:DysonToGoDeployScript"
else
    echo "Invalid target script."
    exit 1
fi

file="foundry.toml"
map_key="\[profile.default\]"
new_solc_version="solc_version = '$solc_version'"
new_optimizer_runs="optimizer_runs = $optimizer_runs"

# search for optimizer_runs and delete it
if grep -q "optimizer_runs" "$file"; then
    sed -i '' '/optimizer_runs/d' "$file"
else
    echo "Search string 'optimizer_runs' not found in the file."
fi

# search for solc_version and delete it
if grep -q "solc_version" "$file"; then
    sed -i '' '/solc_version/d' "$file"
else
    echo "Search string 'solc_version' not found in the file."
fi

# Apply new optimizer_runs and solc_version
# rpc_url example:
# https://polygonzkevm-mainnet.g.alchemy.com/v2/{ALCHEMY_API_KEY}
# https://sepolia.infura.io/v3/05659145fa4c469e98a8584429872035
# https://polygonzkevm-testnet.g.alchemy.com/v2/nYG_CkRC5-Tb5I5VO4mXGiGIdFcWj1bd
if grep -q "$map_key" "$file"; then
    sed -i '' "s/$map_key/$map_key\n$new_optimizer_runs\n$new_solc_version/" "$file"
    echo "Apply optimizer_runs and solc_version successful."
else
    echo "Search string '\[profile.default\]' not found in the file."
fi

# echo "forge script $target_script --rpc-url $rpc_url --use $solc_version --optimizer-runs $optimizer_runs -vvvv --broadcast"
# Run the target script
# target script path example: src/script/MainnetDeployPart2.s.sol:MainnetDeployScriptPart2
# eip 1559 error => --legacy
# verify code: forge verify-contract $contractAddress $contractName --etherscan-api-key $scanApiKey --watch --verifier-url $verifyUrl
# xlayer example :https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER_TESTNET

echo forge script $target_script --rpc-url $rpc_url --use $solc_version --optimizer-runs $optimizer_runs -vvvv --broadcast --legacy
if [ "$is_broadcast" = "y" ]; then
    forge script $target_script --rpc-url $rpc_url --use $solc_version --optimizer-runs $optimizer_runs -vvvv --broadcast --legacy >> log
else
    forge script $target_script --rpc-url $rpc_url --use $solc_version --optimizer-runs $optimizer_runs --verifier-url https://www.oklink.com/api/v5/explorer/contract/verify-source-code-plugin/XLAYER -vvvv --legacy >> log
fi

start=false
while read line; do
    if [ "$line" = "{" ]; then
        start=true
    fi
    if [ "$start" = true ]; then
        echo "$line" >> config.json
    fi
    if [ "$line" = "}" ]; then
        echo "}" >> config.json
        break
    fi
done < log