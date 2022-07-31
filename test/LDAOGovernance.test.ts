import { expect } from 'chai';
import hre from 'hardhat'
import { time } from '@nomicfoundation/hardhat-network-helpers';
import { LDAOGovernance } from '../typechain-types';

describe("LDAOGovernance", () => {
    let gov: LDAOGovernance;
    beforeEach(async function () { 
        const votePeriod = 28 * 24 * 60 * 60;
        const LDAOGovernance = await hre.ethers.getContractFactory('LDAOGovernance');
        gov = await LDAOGovernance.deploy(votePeriod, {gasLimit: 30000000})
    });

    it("Should create valid proposal", async () => {
        const now = await time.latest() + 600;


        const ipfs = "QmaC8pyAL2TvhmejNrTrJFA8voAr5QxhU8Ltf4LVVdona7";

        const proposalId = await gov.createProposal(now, ipfs);
        const reciept = await proposalId.wait()
        expect(await gov.getProposalFolder(parseInt(reciept.events![0].args![1]))).to.equal(ipfs);
    });

    it ("Should fail to create proposal due to past time start date", async () => {
        const now = await time.latest() - 600;

        const ipfs = "QmaC8pyAL2TvhmejNrTrJFA8voAr5QxhU8Ltf4LVVdona7";

        await expect(gov.createProposal(now, ipfs)).to.be.revertedWith("Start Time must not be before current time.");
    });

    it("Should get voter when voter registered", async () => {
        const addr = '0x97f489956541c262373f7FfC751BA8009E3AB600';
        const [sender] = await hre.ethers.getSigners();
        await gov.setInvestorContractAddress(sender.address);
        await gov.registerVoter(addr)
        expect(await gov.canVote(addr)).to.equal(true)
    });

    it("Should expect false from can vote if not registered", async () => {
        const addr = '0x97f489956541c262373f7FfC751BA8009E3AB600';
        const [sender] = await hre.ethers.getSigners();
        await gov.setInvestorContractAddress(sender.address);
        expect(await gov.canVote(addr)).to.equal(false);
    });

    it("Should get voter has voted true when voted", async () => {
        const [sender] = await hre.ethers.getSigners();
        await gov.setInvestorContractAddress(sender.address);
        await gov.registerVoter(sender.address)
        expect(await gov.canVote(sender.address)).to.equal(true)

        const now = await time.latest() + 2;

        const ipfs = "QmaC8pyAL2TvhmejNrTrJFA8voAr5QxhU8Ltf4LVVdona7";

        const proposalId = await gov.createProposal(now, ipfs);
        const reciept = await proposalId.wait()
        const id = parseInt(reciept.events![0].args![1]);
        expect(await gov.getProposalFolder(id)).to.equal(ipfs);

        await gov.vote(id, 1)
        expect(await gov.hasVoted(id, sender.address)).to.equal(true);
    });


    it("Should get vote number when voted", async () => {
 const [sender] = await hre.ethers.getSigners();
        await gov.setInvestorContractAddress(sender.address);
        await gov.registerVoter(sender.address)
        expect(await gov.canVote(sender.address)).to.equal(true)

        const now = await time.latest() + 2;

        const ipfs = "QmaC8pyAL2TvhmejNrTrJFA8voAr5QxhU8Ltf4LVVdona7";

        const proposalId = await gov.createProposal(now, ipfs);
        const reciept = await proposalId.wait()
        const id = parseInt(reciept.events![0].args![1]);
        expect(await gov.getProposalFolder(id)).to.equal(ipfs);

        await gov.vote(id, 1);
        expect(await gov.getVote(id, sender.address)).to.equal(1);
    });

    it("Should get revoked if no vote", async () => {
        const [sender] = await hre.ethers.getSigners();
        await gov.setInvestorContractAddress(sender.address);
        await gov.registerVoter(sender.address)
        expect(await gov.canVote(sender.address)).to.equal(true)

        const now = await time.latest() + 2;

        const ipfs = "QmaC8pyAL2TvhmejNrTrJFA8voAr5QxhU8Ltf4LVVdona7";

        const proposalId = await gov.createProposal(now, ipfs);
        const reciept = await proposalId.wait()
        const id = parseInt(reciept.events![0].args![1]);
        expect(await gov.getProposalFolder(id)).to.equal(ipfs);

        await expect(gov.getVote(id, sender.address)).to.be.revertedWith("Voter has not yet voted");
    });
})