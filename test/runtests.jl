using CryptoCurrencies
import CryptoCurrencies: unit, name, BTC, LTC, XMR, ZEC

using Test

currencies = [BTC,LTC,XMR,ZEC]
units = [8,8,8,8]
names = ["Bitcoin","Litecoin","Monero","Zcash"]

for (ccy,u,n) in zip(currencies,units,names)
    @test unit(ccy) == u
    @test name(ccy) == n
end
