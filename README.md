# Micro Farm Manager

A retro pixel art idle farming game built with Godot 4.2. Automate your farm with cute robot helpers, process crops into products, and build your agricultural empire!

## Features

- **Idle/Incremental Gameplay**: Watch your farm grow even when you're away
- **Robot Automation**: Hire cute robots to plant, harvest, process, and sell automatically
- **Supply Chain**: Plant crops → Process into products → Sell for profit
- **Prestige System**: Reset your farm for permanent multipliers and upgrades
- **Offline Progress**: Continue earning gold even when the game is closed
- **Achievements**: Unlock achievements for various milestones
- **Mobile-Optimized**: Touch controls and portrait orientation for mobile play
- **Retro Pixel Art**: Procedurally generated pixel art graphics

## How to Play

1. **Plant Crops**: Select a crop from the crop selector and tap empty plots to plant
2. **Harvest**: When crops are ready (pulsing animation), tap to harvest them
3. **Process Crops**: Use the product panel to convert crops into valuable products
4. **Sell**: Sell crops and products to earn gold
5. **Buy Robots**: Purchase robots to automate tasks:
   - **Harvester Bot**: Automatically harvests ready crops
   - **Planter Bot**: Automatically plants selected crops
   - **Processor Bot**: Automatically processes crops into products
   - **Seller Bot**: Automatically sells crops and products
6. **Prestige**: When you have enough gold, prestige to reset for permanent bonuses

## Crops & Products

### Crops
- **Wheat**: Fast-growing, low cost (5 gold, 5s growth)
- **Carrot**: Medium growth, moderate profit (10 gold, 10s growth)
- **Tomato**: Slower, higher profit (20 gold, 20s growth)
- **Corn**: High investment, high reward (40 gold, 30s growth)
- **Pumpkin**: Premium crop, massive profit (100 gold, 60s growth)

### Products
- **Flour**: Made from wheat (2 wheat → 30 gold)
- **Carrot Cake**: Made from carrots (3 carrots → 100 gold)
- **Tomato Sauce**: Made from tomatoes (2 tomatoes → 150 gold)
- **Popcorn**: Made from corn (1 corn → 150 gold)
- **Pumpkin Pie**: Made from pumpkins (2 pumpkins → 600 gold)

## Robot Costs
- Harvester Bot: 500 gold
- Planter Bot: 750 gold
- Processor Bot: 1,000 gold
- Seller Bot: 1,500 gold

## Prestige System
- Prestige when you've earned 100+ prestige currency (1,000 total gold earned)
- Each prestige level gives:
  - +10% gold multiplier
  - +5% crop growth speed
  - +5% robot speed
- Use prestige currency to buy permanent upgrades

## Running the Game

### Requirements
- Godot Engine 4.2 or later

### Instructions
1. Open Godot
2. Click "Import" and select the `MicroFarmManager` folder
3. Open the project
4. Press F5 or click the Play button to run

### Mobile Export
The project includes export presets for Android and iOS:
- Android: Uses the export preset to build an APK
- iOS: Uses the export preset to build an IPA

## Project Structure
```
MicroFarmManager/
├── scenes/           # Godot scene files
│   ├── main_game.tscn
│   └── plot.tscn
├── scripts/          # GDScript files
│   ├── game_data.gd
│   ├── main_game.gd
│   ├── plot.gd
│   └── pixel_art_generator.gd
├── assets/           # Game assets
│   ├── sprites/
│   └── audio/
├── data/             # Game data files
├── project.godot     # Godot project configuration
├── export_presets.cfg # Export configurations
└── icon.svg          # Game icon
```

## Game Mechanics

### Time System
- Crops grow in real-time (seconds in game = seconds in real life)
- Growth time is affected by prestige multipliers and upgrades
- Offline progress is calculated based on time away and robot automation

### Save System
- Auto-saves every 30 seconds
- Manual save on game close
- Saves to local storage (`user://save_data.json`)
- Includes all progress: gold, inventory, robots, achievements, etc.

### Achievements
- First Harvest: Harvest your first crop
- Farmer: Harvest 100 crops
- Master Farmer: Harvest 1,000 crops
- Getting Rich: Earn 10,000 gold total
- Millionaire: Earn 1,000,000 gold total
- Robot Owner: Buy your first robot
- First Prestige: Prestige for the first time
- Prestige Master: Reach prestige level 5

## Technical Details

- **Engine**: Godot 4.2
- **Language**: GDScript
- **Resolution**: 432x768 (portrait mobile)
- **Art Style**: Procedural pixel art
- **Target Platform**: Mobile (Android/iOS)
- **Save Format**: JSON

## Future Enhancements
- More crop types and products
- Additional robot types with special abilities
- Seasonal events and limited-time crops
- Social features (leaderboards, gifts)
- Sound effects and music
- More achievements and milestones
- Decorations and farm customization

## License
This is a demo project for educational purposes.