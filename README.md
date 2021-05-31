# What is this?
An ESX garage system with vehicle preview, easy to setup and configure.
More info in the cfx.re topic: https://forum.cfx.re/t/esx-free-esx-beetlegarage-garages-with-vehicle-preview-marbella-vice-style/2993846

## Requirements
* [ESX Legacy](https://github.com/esx-framework/es_extended/tree/legacy) (Tested with 1.1 and 1.2)
* [esx_vehicleshop](https://github.com/esx-framework/esx_vehicleshop)
* OneSync

## Features
* Easy to setup and configure.
* Vehicle preloading and preview (also including the vehicle modifications).
* Multiple spawn points per garage.
* Locale support.

## Installation
- Import the "import_me.sql" into your database.
- Start the resource with "start esx_beetlegarage" after putting it into your resources folder.
- Easy as that!

# Frequently asked questions
## How to add garages?
There is an example in the config.lua of how to do it, check it out.

## Is this optimized?
Yes, it is. 0.01ms while idling and 0.2ms while near the markers. The vehicle preview is not CPU intensive **IF** vehicle preloading is enabled.

## What is ReleaseMemory and LoadOnlyRequested?
**You probably dont need this**. These 2 options are for servers that have badly optimized vehicle mods. ReleaseMemory will unload the vehicle models from the memory when the player leaves the garage, making the player load them again when it enters the garage again.
LoadOnlyRequested will free the memory when changing vehicle instead of doing it when you leave the garage, just like esx_vehicleshop.
