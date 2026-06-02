// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

interface ISeverityCalculator {
    enum Severity { LOW, MEDIUM, HIGH, CRITICAL }
    function calculateReward(Severity severity, uint256 tvlAffected) external view returns (uint256);
}

contract BugBountyPlatform is ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    enum BugStatus { SUBMITTED, VALIDATED, PAID, DISPUTED, REJECTED }
    enum Severity { LOW, MEDIUM, HIGH, CRITICAL }

    struct Bounty {
        address creator;
        address targetContract;
        Severity severity;
        uint256 rewardPool;
        uint256 rewardPerBug;
        uint256 maxSubmissions;
        uint256 submissionsCount;
        uint256 createdAt;
        bool active;
    }

    struct BugSubmission {
        uint256 bountyId;
        address submitter;
        bytes32 descriptionHash;
        Severity severity;
        uint256 submittedAt;
        BugStatus status;
        uint256 payout;
    }

    IERC20 public rewardToken;
    ISeverityCalculator public severityCalculator;

    uint256 public bountyCounter;
    uint256 public submissionCounter;
    uint256 public disputeWindow = 7 days;

    mapping(uint256 => Bounty) public bounties;
    mapping(uint256 => BugSubmission) public submissions;
    mapping(uint256 => uint256[]) public bountySubmissions;
    mapping(address => uint256[]) public userSubmissions;
    mapping(uint256 => bool) public submissionDisputed;

    event BountyCreated(uint256 indexed bountyId, address indexed creator, address target, Severity severity, uint256 rewardPool);
    event BugSubmitted(uint256 indexed submissionId, uint256 indexed bountyId, address indexed submitter, Severity severity);
    event BugValidated(uint256 indexed submissionId, uint256 payout);
    event RewardPaid(uint256 indexed submissionId, address indexed submitter, uint256 amount);
    event DisputeRaised(uint256 indexed submissionId, address indexed disputer);

    constructor(address _rewardToken, address _severityCalculator) Ownable(msg.sender) {
        rewardToken = IERC20(_rewardToken);
        severityCalculator = ISeverityCalculator(_severityCalculator);
    }

    function createBounty(
        address targetContract,
        Severity severity,
        uint256 rewardPool,
        uint256 maxSubmissions
    ) external nonReentrant returns (uint256) {
        require(maxSubmissions > 0, "Max submissions must be positive");

        rewardToken.safeTransferFrom(msg.sender, address(this), rewardPool);

        uint256 bountyId = bountyCounter++;
        uint256 rewardPerBug = rewardPool / maxSubmissions;

        bounties[bountyId] = Bounty({
            creator: msg.sender,
            targetContract: targetContract,
            severity: severity,
            rewardPool: rewardPool,
            rewardPerBug: rewardPerBug,
            maxSubmissions: maxSubmissions,
            submissionsCount: 0,
            createdAt: block.timestamp,
            active: true
        });

        emit BountyCreated(bountyId, msg.sender, targetContract, severity, rewardPool);
        return bountyId;
    }

    function submitBug(
        uint256 bountyId,
        bytes32 descriptionHash,
        Severity severity
    ) external nonReentrant returns (uint256) {
        Bounty storage bounty = bounties[bountyId];
        require(bounty.active, "Bounty not active");
        require(bounty.submissionsCount < bounty.maxSubmissions, "Submissions maxed");
        require(block.timestamp < bounty.createdAt + 30 days, "Bounty expired");

        uint256 submissionId = submissionCounter++;
        submissions[submissionId] = BugSubmission({
            bountyId: bountyId,
            submitter: msg.sender,
            descriptionHash: descriptionHash,
            severity: severity,
            submittedAt: block.timestamp,
            status: BugStatus.SUBMITTED,
            payout: bounty.rewardPerBug
        });

        bountySubmissions[bountyId].push(submissionId);
        userSubmissions[msg.sender].push(submissionId);
        bounty.submissionsCount++;

        emit BugSubmitted(submissionId, bountyId, msg.sender, severity);
        return submissionId;
    }

    function validateBug(uint256 submissionId) external onlyOwner {
        BugSubmission storage submission = submissions[submissionId];
        require(submission.status == BugStatus.SUBMITTED, "Not pending");
        require(block.timestamp > submission.submittedAt + disputeWindow, "Dispute window active");

        submission.status = BugStatus.VALIDATED;
        bounties[submission.bountyId].rewardPool -= submission.payout;

        emit BugValidated(submissionId, submission.payout);
    }

    function payoutReward(uint256 submissionId) external nonReentrant {
        BugSubmission storage submission = submissions[submissionId];
        require(submission.status == BugStatus.VALIDATED, "Not validated");

        submission.status = BugStatus.PAID;
        rewardToken.safeTransfer(submission.submitter, submission.payout);

        emit RewardPaid(submissionId, submission.submitter, submission.payout);
    }

    function disputeValidation(uint256 submissionId) external {
        BugSubmission storage submission = submissions[submissionId];
        require(submission.status == BugStatus.SUBMITTED, "Not submitted");
        require(block.timestamp <= submission.submittedAt + disputeWindow, "Dispute window closed");
        require(!submissionDisputed[submissionId], "Already disputed");

        submission.status = BugStatus.DISPUTED;
        submissionDisputed[submissionId] = true;

        emit DisputeRaised(submissionId, msg.sender);
    }

    function rejectBug(uint256 submissionId) external onlyOwner {
        BugSubmission storage submission = submissions[submissionId];
        require(submission.status == BugStatus.SUBMITTED || submission.status == BugStatus.DISPUTED, "Not rejectable");

        submission.status = BugStatus.REJECTED;
    }

    function getBountySubmissions(uint256 bountyId) external view returns (uint256[] memory) {
        return bountySubmissions[bountyId];
    }

    function getUserSubmissions(address user) external view returns (uint256[] memory) {
        return userSubmissions[user];
    }

    function setDisputeWindow(uint256 _window) external onlyOwner {
        disputeWindow = _window;
    }
}
