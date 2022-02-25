from brownie import FundMe, accounts

from scripts.helpful_scripts import get_account

def fund():
    fund_me = FundMe[-1]
    entrance_fee = fund_me.getEntranceFee()
    print( entrance_fee )
    print( "Funding")
    fund_me.fund( {
        "from": get_account(),
        "value": entrance_fee
    })

def withdraw():
    fund_me = FundMe[-1]
    fund_me.withdraw({
        "from": get_account()
    })

def main():
    fund()
    withdraw()