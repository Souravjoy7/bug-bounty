// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";

contract SeverityCalculator is Ownable {
    enum Severity { LOW, MEDIUM, HIGH, CRITICAL }

    uint256 public lowMultiplier = 1;
    uint256 public mediumMultiplier = 5;
    uint256 public highMultiplier = 20;
    uint256 public criticalMultiplier = 50;
    uint256 public baseReward = 0.01 ether;

    uint256 public minRewardLow = 0.001 ether;
    uint256 public minRewardMedium = 0.01 ether;
    uint256 public minRewardHigh = 0.1 ether;
    uint256 public minRewardCritical = 1 ether;
    uint256 public maxReward = 100 ether;

    event MultipliersUpdated(uint256 low, uint256 medium, uint256 high, uint256 critical);

    constructor() Ownable(msg.sender) {}

    function setRewardMultiplier(
        uint256 _low,
        uint256 _medium,
        uint256 _high,
        uint256 _critical
    ) external onlyOwner {
        require(_low > 0 && _medium > _low && _high > _medium && _critical > _high, "Invalid ordering");
        lowMultiplier = _low;
        mediumMultiplier = _medium;
        highMultiplier = _high;
        criticalMultiplier = _critical;
        emit MultipliersUpdated(_low, _medium, _high, _critical);
    }

    function calculateReward(Severity severity, uint256 tvlAffected) external view returns (uint256) {
        uint256 multiplier;
        uint256 minReward;

        if (severity == Severity.LOW) {
            multiplier = lowMultiplier;
            minReward = minRewardLow;
        } else if (severity == Severity.MEDIUM) {
            multiplier = mediumMultiplier;
            minReward = minRewardMedium;
        } else if (severity == Severity.HIGH) {
            multiplier = highMultiplier;
            minReward = minRewardHigh;
        } else {
            multiplier = criticalMultiplier;
            minReward = minRewardCritical;
        }

        uint256 reward = baseReward * multiplier;
        reward = reward + (tvlAffected * multiplier) / 1000;

        if (reward < minReward) {
            reward = minReward;
        }
        if (reward > maxReward) {
            reward = maxReward;
        }

        return reward;
    }

    function getRewardRange(Severity severity) external view returns (uint256 minR, uint256 maxR) {
        if (severity == Severity.LOW) {
            return (minRewardLow, baseReward * lowMultiplier * 10);
        } else if (severity == Severity.MEDIUM) {
            return (minRewardMedium, baseReward * mediumMultiplier * 10);
        } else if (severity == Severity.HIGH) {
            return (minRewardHigh, baseReward * highMultiplier * 10);
        } else {
            return (minRewardCritical, maxReward);
        }
    }

    function setBaseReward(uint256 _baseReward) external onlyOwner {
        require(_baseReward > 0, "Base must be positive");
        baseReward = _baseReward;
    }

    function setMaxReward(uint256 _maxReward) external onlyOwner {
        require(_maxReward > 0, "Max must be positive");
        maxReward = _maxReward;
    }
}
