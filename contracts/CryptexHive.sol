// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title CryptexHive
 * @notice A decentralized crypto incubation and funding platform where innovators can propose blockchain ideas,
 *         investors can fund them, and the community can track their progress transparently.
 */
contract Project {
    address public admin;
    uint256 public ideaCount;

    struct Idea {
        uint256 id;
        address creator;
        string title;
        string description;
        uint256 fundsRaised;
        uint256 goalAmount;
        bool funded;
    }

    mapping(uint256 => Idea) public ideas;
    mapping(uint256 => mapping(address => uint256)) public contributions;

    event IdeaSubmitted(uint256 indexed id, address indexed creator, string title, uint256 goalAmount);
    event IdeaFunded(uint256 indexed id, address indexed funder, uint256 amount);
    event FundingCompleted(uint256 indexed id, uint256 totalFunds);
    event FundsWithdrawn(uint256 indexed id, address indexed creator, uint256 amount);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Submit a new blockchain innovation idea for funding
     * @param _title Idea title
     * @param _description Brief description
     * @param _goalAmount Funding goal in wei
     */
    function submitIdea(string memory _title, string memory _description, uint256 _goalAmount) external {
        require(bytes(_title).length > 0, "Title required");
        require(bytes(_description).length > 0, "Description required");
        require(_goalAmount > 0, "Goal amount must be greater than zero");

        ideaCount++;
        ideas[ideaCount] = Idea(ideaCount, msg.sender, _title, _description, 0, _goalAmount, false);

        emit IdeaSubmitted(ideaCount, msg.sender, _title, _goalAmount);
    }

    /**
     * @notice Fund a specific blockchain idea
     * @param _id Idea ID
     */
    function fundIdea(uint256 _id) external payable {
        Idea storage idea = ideas[_id];
        require(_id > 0 && _id <= ideaCount, "Invalid idea ID");
        require(!idea.funded, "Funding already completed");
        require(msg.value > 0, "Funding amount must be greater than zero");

        idea.fundsRaised += msg.value;
        contributions[_id][msg.sender] += msg.value;

        emit IdeaFunded(_id, msg.sender, msg.value);

        if (idea.fundsRaised >= idea.goalAmount) {
            idea.funded = true;
            emit FundingCompleted(_id, idea.fundsRaised);
        }
    }

    /**
     * @notice Withdraw raised funds after successful funding
     * @param _id Idea ID
     */
    function withdrawFunds(uint256 _id) external {
        Idea storage idea = ideas[_id];
        require(msg.sender == idea.creator, "Only creator can withdraw");
        require(idea.funded, "Funding not yet completed");
        require(idea.fundsRaised > 0, "No funds to withdraw");

        uint256 amount = idea.fundsRaised;
        idea.fundsRaised = 0;

        payable(idea.creator).transfer(amount);
        emit FundsWithdrawn(_id, idea.creator, amount);
    }

    /**
     * @notice Get idea details by ID
     * @param _id Idea ID
     * @return Idea struct containing full details
     */
    function getIdea(uint256 _id) external view returns (Idea memory) {
        require(_id > 0 && _id <= ideaCount, "Invalid idea ID");
        return ideas[_id];
    }
}
// 
End
// 
