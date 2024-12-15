-- Use the SceneSense database
USE scenesense;

-- Drop tables
DROP TABLE IF EXISTS RehearsalScene;
DROP TABLE IF EXISTS SceneCharacter;
DROP TABLE IF EXISTS Role;
DROP TABLE IF EXISTS Rehearsal;
DROP TABLE IF EXISTS Scene;
DROP TABLE IF EXISTS Characters;
DROP TABLE IF EXISTS Actor;
DROP TABLE IF EXISTS Production;
DROP TABLE IF EXISTS Play;

-- Create the Play table
CREATE TABLE IF NOT EXISTS Play (
    play_id INT PRIMARY KEY AUTO_INCREMENT,
    play_title VARCHAR(100) NOT NULL,
    play_author VARCHAR(100) 
);

-- Create the Production table
CREATE TABLE IF NOT EXISTS Production (
    production_id INT PRIMARY KEY AUTO_INCREMENT,
    production_name VARCHAR(100) NOT NULL,
    production_description VARCHAR(255),
    premiere_date DATE, 
    billboard_image VARCHAR(255),
    play_id INT NOT NULL,
    FOREIGN KEY (play_id) REFERENCES Play(play_id)
);

-- Create the Actor table
CREATE TABLE IF NOT EXISTS Actor (
    actor_id INT PRIMARY KEY AUTO_INCREMENT,
    actor_name VARCHAR(50) NOT NULL,
	actor_email VARCHAR(50) NOT NULL,
	actor_phone VARCHAR(20)
);

-- Create the Characters table
CREATE TABLE IF NOT EXISTS Characters (
    character_id INT PRIMARY KEY AUTO_INCREMENT,
    character_name VARCHAR(100) NOT NULL,
    character_description VARCHAR(255),
    play_id INT NOT NULL,
    FOREIGN KEY (play_id) REFERENCES Play(play_id)
);

-- Create the Scene table
CREATE TABLE IF NOT EXISTS Scene (
    scene_id INT PRIMARY KEY AUTO_INCREMENT,
    scene_title VARCHAR(100) NOT NULL,
    sequence_number INT NOT NULL,
    play_id INT NOT NULL,
    FOREIGN KEY (play_id) REFERENCES Play(play_id)
);

-- Create the Role table
CREATE TABLE IF NOT EXISTS Role (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    actor_id INT NOT NULL,
    production_id INT NOT NULL,
    character_id INT, 
    FOREIGN KEY (actor_id) REFERENCES Actor(actor_id),
    FOREIGN KEY (production_id) REFERENCES Production(production_id),
    FOREIGN KEY (character_id) REFERENCES Characters(character_id)
);

-- Create the SceneCharacter table
CREATE TABLE IF NOT EXISTS SceneCharacter (
    scene_id INT NOT NULL,
    character_id INT NOT NULL,
    PRIMARY KEY (scene_id, character_id),
    FOREIGN KEY (scene_id) REFERENCES Scene(scene_id),
    FOREIGN KEY (character_id) REFERENCES Characters(character_id)
);

-- Create the Rehearsal table
CREATE TABLE IF NOT EXISTS Rehearsal (
    rehearsal_id INT PRIMARY KEY AUTO_INCREMENT,
    rehearsal_date DATE NOT NULL,
    rehearsal_start_time TIME NOT NULL,
    rehearsal_end_time TIME NOT NULL,
    production_id INT NOT NULL,
    FOREIGN KEY (production_id) REFERENCES Production(production_id)
);

-- Create the RehearsalScene table
CREATE TABLE IF NOT EXISTS RehearsalScene (
    rehearsal_id INT NOT NULL,
    scene_id INT NOT NULL,
    duration_minutes INT NOT NULL,
    PRIMARY KEY (rehearsal_id, scene_id),
    FOREIGN KEY (rehearsal_id) REFERENCES Rehearsal(rehearsal_id),
    FOREIGN KEY (scene_id) REFERENCES Scene(scene_id)
);

-- Insert data into Play table
INSERT INTO Play (play_title, play_author)
VALUES 
    ('Julius Caesar', 'William Shakespeare'),
    ('Rosencrantz and Guildenstern are Dead', 'Tom Stoppard');

-- Insert data into Production table
INSERT INTO Production (production_name, production_description, 
						premiere_date, play_id)
VALUES 
    ('Julius Caesar the Musical', 
    'Based on the play Julius Caesar', NULL, 1),
    ('Rosencrantz and Guildenstern are Dead', 
    'Based on the play of the same name', NULL, 2);

-- Insert data into Actor table
INSERT INTO Actor (actor_name, actor_email, actor_phone)
VALUES 
  ('Peter O’Toole', 'peter.otoole@example.com',  NULL),
  ('Will Smith', 'will.smith@example.com', NULL),
  ('Brad Pitt', 'brad.pitt@example.com', NULL),
  ('Russell Crowe', 'russell.crowe@example.com', NULL),
  ('Angelina Jolie', 'angelina.jolie@example.com', NULL),
  ('Scarlett Johansson', 'scarlett.johansson@example.com', NULL);


-- Insert data into Characters table
INSERT INTO Characters (character_name, character_description, play_id)
VALUES 
    ('Caesar', NULL, 1),
    ('Brutus', NULL, 1),
    ('Cassius', NULL, 1),
    ('Antony', NULL, 1),
    ('Portia', NULL, 1);

-- Insert data into Scene table
INSERT INTO Scene (scene_title, sequence_number, play_id)
VALUES 
    ('Act 3 Scene 1', 13, 1),
    ('Act 3 Scene 2', 14, 1);

-- Insert data into Role table
INSERT INTO Role (actor_id, production_id, character_id)
VALUES 
    (1, 1, 1), -- Peter O'Toole as Caesar
    (2, 1, 2), -- Will Smith as Brutus
    (3, 1, 3), -- Brad Pitt as Cassius
    (4, 1, 4), -- Russell Crowe as Antony
    (5, 1, 5), -- Angelina Jolie as Portia
    (6, 1, NULL); -- Scarlett Johansson with no role

-- Insert data into SceneCharacter table
-- Scene 1 includes Caesar, Brutus, Cassius, Antony
INSERT INTO SceneCharacter (scene_id, character_id)
VALUES 
    (1, 1), -- Caesar
    (1, 2), -- Brutus
    (1, 3), -- Cassius
    (1, 4); -- Antony

-- Scene 2 includes Brutus, Cassius, Antony
INSERT INTO SceneCharacter (scene_id, character_id)
VALUES 
    (2, 2), -- Brutus
    (2, 3), -- Cassius
    (2, 4); -- Antony

-- Insert data into Rehearsal table
INSERT INTO Rehearsal (rehearsal_date, rehearsal_start_time, 
						rehearsal_end_time, production_id)
VALUES 
    ('2021-03-15', '14:00:00', '18:00:00', 1),
    ('2021-03-16', '14:00:00', '18:00:00', 1),
    ('2021-03-17', '14:00:00', '18:00:00', 1);

-- Insert data into RehearsalScene table
-- Rehearsal 1: Scene 1 and Scene 2
INSERT INTO RehearsalScene (rehearsal_id, scene_id, duration_minutes)
VALUES 
    (1, 1, 120),
    (1, 2, 120);

-- Rehearsal 2: Scene 2
INSERT INTO RehearsalScene (rehearsal_id, scene_id, duration_minutes)
VALUES 
    (2, 2, 240);

-- Rehearsal 3: Scene 1 and Scene 2
INSERT INTO RehearsalScene (rehearsal_id, scene_id, duration_minutes)
VALUES 
    (3, 1, 60),
    (3, 2, 180);
    
    
