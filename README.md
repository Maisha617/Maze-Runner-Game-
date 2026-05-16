## The Maze Runner Game

### Overview
The Maze Runner is an exploration game where the player is set in first-person perspective mode and navigates the 3D maze while encountering monsters, 2D mini-games and the chance to collect power-ups. The player’s choices determine if they can progress through the levels and ultimately escape the maze

This project is created by a team of 4 Drexel University students for Computing and Informatics Design I, II courses.

### Features
- #### 3D First-Person Gameplay 
  - Smooth movement, sprinting, collision, and immersive camera
- #### Player Model
  - Human body with visible arm movement when running 
- #### Multiple Levels
  - Five levels with distinct visual themes and sound effects
- #### 2D Mini-Games Integrated
  - Pathways can trigger any of the three mini-game events. Winning progresses player to next level, losing respawns player to current level
    - Memory Card: Flip and match 10 pairs of matching cards to progress
    - Flappy Bird: Navigate through obstacles and reach a score of 10 
    - Tic-Tac-Toe: Play against a computer opponent and win 5 matches 
- #### Revive Power-Up
  - Power-up randomly spawns in the first level. Player can collect and use to skip mini-games
- #### The Griever Monster
  - Pathways can trigger the 3D monster which runs to the player and kills them, respawning player to current level
- #### Full Audio Integration
  - Background music and sound effects based on player input and event triggers 

### Maisha’s Contributions
- Served as the Model Designer and Product Owner for all sprint reviews 
- Assisted in the creation of the base model of the 3D maze
- Created and designed the environments of all levels 1-5, applying PBR materials for textures, applying .exr files for HDRI skies, adding and refining lighting, shadows, fog, ambience, etc
- Implemented all sound effects and music using .wav audio files
- Developed all aspects of the memory card mini-game, including working with 2D sprite assets, creating and implementing animations, and scripting all gameplay logic
- Assisted in the code development for linking maze pathways to trigger the mini-games or monster
- Wrote code for player spawn and level progress, implementing this among several script files
- Assisted in the implementation of player and camera controls, including head-bob movement
### Instructions on how to run the game
1. Install Godot Game Engine (latest version is Godot 4) 
2. Clone or download this repository
3. Launch Godot and click import
4. Navigate to the Maze-Runner-Game project folder and import the file “project.godot”
5. Press F5 or click the Play button in the top-right corner 
