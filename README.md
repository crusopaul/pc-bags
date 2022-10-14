# pc-bags
A self-cleaning, generic bag resource for qb-core. Supports creation of bags with specific weight allotments, number of slots, and expiration time.

## Config
All configuration is done through the [server/config.lua](server/config.lua) file.

## Dependencies
This resource requires [rpemotes](https://github.com/TayMcKenzieNZ/rpemotes) to run. If you are using an alternative, I would recommend manually tweaking the export calls in the [client/main.lua](client/main.lua) file.

## Installation
To install pc-bags:
- Place the latest release into the resources folder
- Copy any custom item images from html/images into your inventory resource's html/images
- Add custom item entries into qb-core/shared/items.lua
- Ensure pc-bags

## License
This resource is licensed under the MIT License - feel free to do as you desire with it so long as the terms of the [LICENSE](LICENSE) are met.
