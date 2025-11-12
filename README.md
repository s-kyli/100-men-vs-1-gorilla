# 100 men vs 1 gorilla

This is an asymmetrical pvp game I made in 3 days where a team of 100 players must coordinate to defeat one overpowered Gorilla (which is also a player), attracting over 39,000 visits.\
https://www.roblox.com/games/117826759571157/100-Players-vs-Gorilla

<img width="600" height="300" alt="image" src="https://github.com/user-attachments/assets/8d596ad8-2915-44fa-af42-d09b152269a6" />


**Purpose**:

So back in May 2025, there was this meme on Instagram called "100 men vs 1 gorilla". It was the debate about who would win: 100 men or 1 gorilla? This gave me the idea to solo-develop this Roblox game. My goal was to build a "many vs 1" combat scenario, which presented unique technical challenges in networking and gameplay scripting.

**Features**:

Custom ability system - a modular system to handle the Gorilla's unique skills (punch and slam)\
Player tool system - Managed the networking and combat logic for player items like the melee hammer and the bear trap.\
Round-based gameplay - fast-paced rounds where players hunt the Gorilla, or are hunted by it.

**Challenges I faced**:

Balancing. This is a big one. I went through *hours* of testing with my friends (thank yall) to make sure the game is balanced on all servers, big or small. I implemented a health-scaling for the Gorilla, so it is easier to kill for servers with less people, and so it is much harder to kill the Gorilla (teamwork is necessary) for larger servers.\
Lua OOP framework (metatables): I was just getting into Roblox Lua's OOP framework, and I had to learn everything from scratch. I built two classes -- one for the melee hammer and the other for the Gorilla's abilities.

Also my first time using git+VSCODE on my own! It was very confusing at first, but I'll get better.


