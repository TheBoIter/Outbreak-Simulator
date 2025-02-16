/*
= 2020.5.21. =
Outbreak simulator inspired by the ongoing COVID-19 pandemic and the game "Plague Inc." by Ndemic Creations
==============
LEGEND:

Small red particles: viral particles
Yellow zone: Quarantine
Black box: Shopping centre

Blue dot: Healthy/Suspectible
Red dot: Infected & showing symtoms. Will be taken to the quarantine after a certain time
Orange dot: Infected, but not showing symptoms (they still spread it, but not as much)
Green dot: Recovered & immune
Black dot: Dead

The secret key is "Control".
*/

// THE SETUP
var viri = [];
var people = [];
var infectedAmount = 0;
var mortalityRate = 15;
var time = 1000;
var mutationRate = 1;
var scene = 0;

// VIRUS CONSTRUCTOR
var Virus = function(x, y, speedX, speedY, lifespan) {
    this.position = new PVector(x, y);
    this.timeToLive = lifespan;
    this.velocity = new PVector(speedX, speedY);
    this.mortalityRate = mortalityRate;
    this.mutationRate = mutationRate;
};

//VIRUS PROTOTYPES:INFECT, UPDATE, RESTRICT, DISPLAY, AND MUTATE
Virus.prototype.infect = function(person) {
    var s = random(0, 100);
    if (round(this.position.x) === round(person.position.x) && round(this.position.y) === round(person.position.y) && person.state === "HEALTHY" && s > 10) {
        person.state = "INFECTED";
        infectedAmount++;
        this.timeToLive = 0;
    }
    else if (round(this.position.x) === round(person.position.x) && round(this.position.y) === round(person.position.y) && person.state === "HEALTHY" && s < 10) {
        person.state = "ASYMTOMATIC";
        infectedAmount++;
        this.timeToLive = 0;
    }
};

Virus.prototype.update = function() {
    this.velocity.normalize();
    this.velocity.mult(2);
    this.position.add(this.velocity);
};

Virus.prototype.restrict = function() {
    if (this.position.y > 595) {
        this.velocity = new PVector(random(-1, 1), random(-1, 0));
    }
    else if (this.position.x > 595) {
        this.velocity = new PVector(random(-1, 0), random(-1, 1));
    }
    else if (this.position.y < 5) {
        this.velocity = new PVector(random(-1, 1), random(0, 1));
    }
    else if (this.position.x < 5) {
       this.velocity = new PVector(random(0, 1), random(-1, 1));
    }
    else if (this.position.x < 200 && this.position.y < 215) {
        this.position.x = random(0, 600);
        this.position.y = random(0, 600);
    }
};

Virus.prototype.display = function() {
    fill(255, 0, 0);
    ellipse(this.position.x, this.position.y, 3, 3);
};

// THIS ONE EXISTS BECAUSE THE RECOVER PROTOTYPE NEEDS A VIRUS
// THAT DOESN'T GET SPLICED TO REFER TO
var dummy = new Virus();

// MOVER CONSTRUCTER
var Mover = function (x, y) {
    this.position = new PVector(x, y);
    this.state = "HEALTHY";
    this.time = time;
    this.quarantined = false;
};

// MOVER PROTOTYPES: UPDATE, RESTRICT, DISPLAY, RECOVER, IN-QUARANTINE, SOCIAL DISTANCE, AND SHOP
Mover.prototype.update = function() {
    var something = 0;
    var move = new PVector(random(-400, 400), random(-400, 400));
    move.normalize();
    move.mult(2);
    this.position.add(move);
    if (this.state === "INFECTED" && something%7 === 0 && !this.quarantined) {
        var cough = new Virus(this.position.x, this.position.y, random(-1, 1), random(-1, 1), 25);
        viri.push(cough);
    }
    else if (this.state === "ASYMTOMATIC" && something%10 === 0 && !this.quarantined) {
        var cough = new Virus(this.position.x, this.position.y, random(-1, 1), random(-1, 1), 15);
        viri.push(cough);
    }
    something++;
};

Mover.prototype.restrict = function() {
    if (this.position.y > 595) {
        this.position.y = 595;
    }
    else if (this.position.x > 595) {
        this.position.x = 595;
    }
    else if (this.position.y < 5) {
        this.position.y = 5;
    }
    else if (this.position.x < 5) {
        this.position.x = 5;
    }
    else if (this.position.x < 200 && this.position.y < 215 && !this.quarantined) {
        this.position.x = random(0, 600);
        this.position.y = random(0, 600);
    }
};

Mover.prototype.display = function() {
    if (this.state === "HEALTHY") {
        noStroke();
        fill(17, 0, 255);
        ellipse(this.position.x, this.position.y, 10, 10);
    }
    else if (this.state === "INFECTED") {
        noStroke();
        fill(255, 0, 115);
        ellipse(this.position.x, this.position.y, 10, 10);
        this.time -= 1;
    }
    else if (this.state === "IMMUNE") {
        noStroke();
        fill(0, 255, 30);
        ellipse(this.position.x, this.position.y, 10, 10);
    }
    else if (this.state === "ASYMTOMATIC") {
        noStroke();
        fill(255, 170, 0);
        ellipse(this.position.x, this.position.y, 10, 10);
        this.time -= 1;
    }
    else if (this.state === "DEAD") {
        noStroke();
        fill(0, 0, 0);
        ellipse(this.position.x, this.position.y, 10, 10);
    }
};

Mover.prototype.recover = function(pathogen) {
    if (this.time === 0) {
        // infectedAmount--;
        var rate = random(0, 100);
        if (rate < pathogen.mortalityRate) {
            this.state = "DEAD";
        }
        else {
            this.state = "IMMUNE";
            this.quarantined = false;
        }
    }
};

Mover.prototype.inQuarantine = function() {
    if (this.position.y > 195) {
        this.position.y = 195;
    }
    else if (this.position.x > 195) {
        this.position.x = 195;
    }
    else if (this.position.y < 5) {
        this.position.y = 5;
    }
    else if (this.position.x < 5) {
        this.position.x = 5;
    }
};

Mover.prototype.socialDistance = function(person) {
    var G = 0.1;
    var force = PVector.sub(this.position, person.position);
    var distance = force.mag();
    distance = constrain(distance, 5, 25);
    force.normalize();
    var strength = G / distance / distance;
    force.mult(strength);
    this.position.add(force);
};

Mover.prototype.shop = function() {
    var r = round(random(0, 5000));
    if (r === 1) {
        this.position.x = 300;
        this.position.y = 300;
    }
};

Virus.prototype.mutate = function() {
    var r = round(random(0, 3));
    if (r === 0 && mortalityRate < 100) {
        mortalityRate += 5;
    }
    else if (r === 1) {
        time += 250;
    }
    else if (r === 2) {
        Virus.mortalityRate -= 5;
        time += 500;
    }
    else {
        mutationRate += 1;
    }
};

// CREATION OF THE ARRAYS OF PEOPLE AND VIRI
for (var i = 0; i < 10; i++) {
    var virus = new Virus(random(50, 550), random(50, 550), random(-1, 1), random(-1, 1), 500);
    viri.push(virus);
}

for (var i = 0; i < 150; i++) {
    var person = new Mover(random(50, 550), random(50, 550));
    people.push(person);
}

// DRAW FUNCTION
draw = function() {
    if (scene === 0) {
        fill(0, 0, 0);
        textSize(30);
        text("\nMost people don't read \n the comments at the top of \n programs. Read it now and find \n the right key to press and see \n the simulation. Enjoy!", 100, 100);
    }
    if (scene === 0 && keyIsPressed && keyCode === 17) {
        scene++;
    }
    if (scene === 1) {
        background(255, 255, 255);
        fill(247, 255, 0);
        rect(0, 0, 200, 200);
        fill(0, 0, 0);
        textSize(10);
        text("QUARANTINE", 0, 200);
        rect(300, 300, 20, 20);
        fill(255, 255, 255);
        rect(302, 302, 16, 16, 2);
        if (infectedAmount >= 25) {
            stroke(255, 0, 0);
            line(300, 300, 320, 320);
            line(320, 300, 300, 320);
        }
        if (random(0, 500) <= dummy.mutationRate) {
            dummy.mutate();
        }
        for (var i = 0; i < viri.length; i++) {
            if (viri[i].timeToLive === 0) {
                viri.splice(i, 1);
            }
            else {
                viri[i].timeToLive -= 1;
                viri[i].update();
                viri[i].restrict();
                viri[i].display();
                for (var j = 0; j < people.length; j++) {
                viri[i].infect(people[j]);
                }
            }
        }
        for (var i = 0; i < people.length; i++) {
            people[i].display();
            if (infectedAmount >= 15 && people[i].state === "INFECTED"&& people[i].time <= 900) {
                people[i].quarantined = true;
            }
            if (people[i].quarantined === true) {
                people[i].inQuarantine();
            }
            if (people[i].state !== "DEAD") {
                people[i].update();
                people[i].restrict();
                if (people[i].quarantined !== true && infectedAmount < 25) {
                    people[i].shop();
                }
                if (people[i].state === "INFECTED" || people[i].state === "ASYMTOMATIC") {
                    people[i].recover(dummy);
                }
                for (var j = 0; j < people.length; j++) {
                    if (j !== i && people[i].quarantined !== true && people[j].quarantined !== true) {
                        people[i].socialDistance(people[j]);
                    }
                }
            }
        }
        fill(168, 0, 168);
        text("INFECTED AMOUNT: " + infectedAmount, 300, 595);
    }
};
