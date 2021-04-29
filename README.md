# ULHA

This repo contains the Main Module (`ULHAMain.lua`). The module is hard to read unless you are experienced with lua (Sorry about that 😅)

This README.md file contains all the information you need to use this Library to create unique hashes for any data in [Lua 5.1+](https://www.lua.org/download.html)!

*I do not own Lua.org, Lua, [ennorehling](https://github.com/ennorehling)'s euler project [BigNum.lua](https://github.com/ennorehling/euler/blob/master/BigNum.lua).*
*The above copyright notice, this permission notice, and any copyright notice in the bigNum.lua file shall be included in all copies or substantial portions of the Software.*

# Setup
### Getting The Module
```lua
require("ULHAMain")
```
This returns the main module for the UHAL library. The library name is `Uhash` You have settings to customize and the main method to call.

### Call the hash function
```lua
require("ULHAMain")

local Uhash64 = Uhash:hash(string: Data) 
--             ^^ Returns the ULHA64 (Deafults to 64 digits unless changed in settings)
print(Uhash64) -- Printing the hash to the console.
```
Output: 64 digits of the hash (eg. `0000000000000000000000000000000000000000000000000000000000000000`)

### Changing settings

#### `Data`
```
string Data (Optional)
```
Deafult data. (optional)

#### `HashLength`
```
int HashLength 

Deafult: 64
```
Length of the hashes.

#### `LengthIgnore`
```
int LengthIgnore 

Deafult: 8
```
Length of ignore when padded; this part states the original message length.

#### `PrimeTableLength`
```
int PrimeTableLength 

Deafult: 64
```
Virsitility of the primes; Max Value: 512; Min Value: 8.

#### `UJumbleLength`
```
int UJumbleLength 

Deafult: 48
```
Times hash is jumbled; make sure it isnt a multiple of HashLength.

#### `MainPrimeNumber`
```
int MainPrimeNumber 

Deafult: 64
```
Main Prime Number used for hashing.

### How to change settings
```lua
require("ULHAMain")
Uhash.hashSettings[index] =  value

-- example:
Uhash.hashSettings.HashLength =  128
```
*You can also change settings directly in the main file (`ULHAMain.lua`)*

# API

#### `hash()`
```lua
Uhash:hash(string Data, string Salt (optional))
```
This function will return the ULHA hash of the data.

Optionally, you can add a salt variable aswell that will modify the hash.
