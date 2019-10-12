pragma solidity ^0.5.6;

import "ds-test/test.sol";

import "../../CowriPool.sol";
import "../../ERC20Token.sol";
import "../../testSetup/setupShells.sol";

contract DappTest is DSTest, ShellSetup {

    address shell1;
    address shell2;
    uint256 shell1Liquidity;
    uint256 shell2Liquidity;

    function setUp () public {

        setupPool();
        setupTokens();
        shell1 = setupShellAB();
        shell2 = setupShellABC();

        uint256 amount = 10000 * ( 10 ** 18 );
        uint256 deadline = now + 50;

        shell1Liquidity = pool.depositLiquidity(shell1, amount, deadline);
        shell2Liquidity = pool.depositLiquidity(shell2, amount, deadline);

        pool.activateShell(shell1);
        pool.activateShell(shell2);

        uint256 swapAmount = 100 * (10 ** 18);
        pool.swapByOrigin(address(testA), address(testB), swapAmount, swapAmount / 2, deadline);
        pool.swapByOrigin(address(testB), address(testA), swapAmount, swapAmount / 2, deadline);
        pool.swapByOrigin(address(testA), address(testC), swapAmount, swapAmount / 2, deadline);
        pool.swapByOrigin(address(testC), address(testB), swapAmount, swapAmount / 2, deadline);

    }


    function testWithdrawAfterSwapByOrigin () public {

        uint256 shell1Token1 = pool.getShellBalanceOf(shell1, address(testA));
        uint256 shell1Token2 = pool.getShellBalanceOf(shell1, address(testB));
        assertEq(shell1Token1, 4999291605008382618002);
        assertEq(shell1Token2, 5000708495370531795763);

        uint256 shell2Token1 = pool.getShellBalanceOf(shell2, address(testA));
        uint256 shell2Token2 = pool.getShellBalanceOf(shell2, address(testB));
        uint256 shell2Token3 = pool.getShellBalanceOf(shell2, address(testC));
        assertEq(shell2Token1, 3432651090005588412001);
        assertEq(shell2Token2, 3234087876473015239620);
        assertEq(shell2Token3, 3336220583060966832083);

        uint256 amount = 500 * ( 10 ** 18 );
        uint256 limitAmount = 450 * ( 10 ** 18 );
        uint256 deadline = now + 50;

        uint256[] memory shell1Withdrawal = pool.withdrawLiquidity(shell1, amount, getLimits(2, limitAmount / 2), deadline);
        assertEq(shell1Withdrawal[0], 249964580250419130900);
        assertEq(shell1Withdrawal[1], 25003542476852658978);

        uint256[] memory shell2Withdrawal = pool.withdrawLiquidity(shell2, amount, getLimits(3, limitAmount / 3), deadline);
        assertEq(shell2Withdrawal[0], 171632554500279420600);
        assertEq(shell2Withdrawal[1], 16170439382365076198);
        assertEq(shell2Withdrawal[2], 1668110291530483416);

    }

}