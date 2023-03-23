  pragma solidity ^0.8.0;

contract VerifiableRandom {
    struct Commit {
        bytes32 hash;
        uint256 revealTimestamp;
    }

    mapping(address => Commit) public commits;

    event Committed(address indexed user, bytes32 hash);
    event Revealed(address indexed user, uint256 randomNumber);

    function commit(bytes32 hash) external {
        require(commits[msg.sender].hash == bytes32(0), "Already committed");

        commits[msg.sender] = Commit({
            hash: hash,
            revealTimestamp: block.timestamp + 1 days
        });

        emit Committed(msg.sender, hash);
    }

    function reveal(uint256 randomNumber, uint256 secret) external {
        bytes32 hash = keccak256(abi.encodePacked(randomNumber, secret));
        require(commits[msg.sender].hash == hash, "Invalid hash");
        require(block.timestamp <= commits[msg.sender].revealTimestamp, "Reveal period expired");

        delete commits[msg.sender];
        emit Revealed(msg.sender, randomNumber);
    }
}
