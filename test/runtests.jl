using Currencies
import Currencies: unit, name, code, USD, PHP, HKD, SGD
import Currencies.Crypto: BTC, LTC, XMR

using Test

currencies = [USD,PHP,HKD,SGD]
units = [2,2,2,2]
names = ["US Dollar","Philippine Piso","Hong Kong Dollar","Singapore Dollar"]
codes = [840,608,344,702]

currencies = [BTC,LTC,XMR]
units = [8,8,8]
names = ["Bitcoin","Litecoin","Monero"]

for (ccy,u,n) in zip(currencies,units,names)
    @test unit(ccy) == u
    @test name(ccy) == n
end
