pragma solidity ^0.8.13;
import "forge-std/Test.sol";
import "../src/Counter.sol";

contract CounterTest is Test {
    Counter counter;
    address owner = address(0x1);
    address nonOwner = address(0x2);

    function setUp() public {
        vm.prank(owner);
        counter = new Counter();
    }

    // Unit Tests
    function testInitialState() public {
        assertEq(counter.number(), 0);
        assertEq(counter.owner(), owner);
        assertEq(counter.lastUpdateTimestamp(), block.timestamp);
    }

    function testSetNumber() public {
        uint256 newNumber = 42;
        vm.prank(nonOwner);
        counter.setNumber(newNumber);
        assertEq(counter.number(), newNumber);
        assertEq(counter.userContributions(nonOwner), newNumber);
        assertEq(counter.lastUpdateTimestamp(), block.timestamp);
    }

    function testIncrement() public {
        counter.setNumber(10);
        counter.increment();
        assertEq(counter.number(), 11);
        assertEq(counter.userContributions(address(this)), 11); // 10 from setNumber + 1 from increment
    }

    function testDecrement() public {
        counter.setNumber(10);
        counter.decrement();
        assertEq(counter.number(), 9);
        assertEq(counter.userContributions(address(this)), 11); // 10 from setNumber + 1 from decrement
    }

    function test_RevertWhen_DecrementBelowZero() public {
        counter.setNumber(0);
        vm.expectRevert(bytes("Counter: cannot decrement below 0"));
        counter.decrement();
    }

    function testResetByOwner() public {
        vm.prank(owner); // Ensure owner is calling reset
        counter.setNumber(100);
        counter.reset();
        assertEq(counter.number(), 0);
    }

    function test_RevertWhen_NonOwnerResets() public {
        vm.prank(nonOwner);
        vm.expectRevert(bytes("Counter: only owner can reset"));
        counter.reset();
    }

    // Fuzz Tests
    function testFuzzSetNumber(uint256 x) public {
        vm.assume(x < type(uint256).max);
        counter.setNumber(x);
        assertEq(counter.number(), x);
        assertEq(counter.userContributions(address(this)), x);
    }

    function testFuzzIncrement(uint256 x) public {
        vm.assume(x < type(uint256).max - 1);
        counter.setNumber(x);
        counter.increment();
        assertEq(counter.number(), x + 1);
    }

    function testFuzzDecrement(uint256 x) public {
        vm.assume(x > 0 && x < type(uint256).max);
        counter.setNumber(x);
        counter.decrement();
        assertEq(counter.number(), x - 1);
    }

    function testFuzzMultipleOperations(uint256 x, uint256 y) public {
        vm.assume(x < type(uint256).max - 1);
        vm.assume(y > 0 && y < x);
        counter.setNumber(x);
        counter.decrement();
        counter.increment();
        counter.setNumber(y);
        assertEq(counter.number(), y);
        assertEq(counter.userContributions(address(this)), x + 2); // x from setNumber + 1 from decrement + 1 from increment
    }
}