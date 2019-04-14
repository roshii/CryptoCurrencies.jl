# CryptoCurrencies.jl

[![Build Status](https://travis-ci.org/roshii/CryptoCurrencies.jl.svg?branch=master)](https://travis-ci.org/roshii/CryptoCurrencies.jl)

## Purpose

This package provides accepted cryptocurrency names and codes.

## Data Source

Data for this package was compiled manually and is not meant to be exhaustive.
Please feel free to add any missing entries to the list.

## Usage

```julia
julia> using CryptoCurrencies; import CryptoCurrencies: unit, name, BTC, LTC, XMR, ZEC
julia> for ccy in [BTC,LTC,XMR,ZEC]
       println("Currency: $(ccy)")
       println("Name: $(name(ccy))")
       println("Minor Unit: $(unit(ccy))\n")
       end

Currency: BTC
Name: Bitcoin
Minor Unit: 8

Currency: LTC
Name: Litecoin
Minor Unit: 8

Currency: XMR
Name: Monero
Minor Unit: 8

Currency: ZEC
Name: Zcash
Minor Unit: 8
```
