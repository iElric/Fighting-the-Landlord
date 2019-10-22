import React from 'react';
import ReactDOM from 'react-dom';
import _ from "lodash";

export default function fighting_the_landlord_init(root, channel) {
    ReactDOM.render(<FightingTheLandLord channel={channel} />, root);
}

class FightingTheLandLord extends React.Component {
    constructor(props) {
        super(props);
        this.channel = props.channel;
        this.state = {
            phase: "wait_for_players",
            landlord: "",
            left: { name: "Alex", points: 10, cards: 5 },
            right: {},
            self: {
                name: "Luke",
                points: 20,
                cards: ["5_hearts", "6_hearts", "7_clubs", "8_hearts"],
            },
            active: false,
            previous_play: { position: "right", cards: ["9_hearts", "10_hearts"] },
            selected_index: []
        };

        this.channel
            .join()
            .receive("ok", this.got_view.bind(this))
            .receive("error", resp => { console.log("Unable to join", resp); });

        this.channel.on("player_joined", this.got_view.bind(this));

    }

    componentDidMount() {

        this.refs.canvas.addEventListener("mousedown", this.onDown.bind(this), false);
        const ctx = this.refs.canvas.getContext('2d');
        console.log("mount1");
        this.updateCanvas(ctx);

    }

    componentDidUpdate(prevProps, prevState) {
        if (!(prevState === this.state)) {
            console.log("updateww");
            const ctx = this.refs.canvas.getContext('2d');
            console.log("updatewweeee");
            ctx.clearRect(0, 0, 1500, 1000);
            this.updateCanvas(ctx);
        }

        /*if (this.props.userID !== prevProps.userID) {
            console.log(",");
            //this.fetchData(this.props.userID);
            this.updateCanvas();
        }*/
    }


    got_view(view) {
        if (view.game !== null) {
            this.setState(view.game);
        }
    }

    loadImage(images_path) {
        return new Promise((resolve, reject) => {
            let image = new Image();
            image.addEventListener("load", () => { resolve(image) });
            image.addEventListener("error", (err) => { reject(err) });
            image.src = images_path;
        });
    }

    updateCanvas(ctx) {
        if (this.state.phase == "card_play") {
            this.drawSides(ctx);
            this.drawLandlord(ctx);
            this.drawPreviousPlay(ctx);
            this.drawSelfCards(ctx);
            this.drawButton(ctx);
        }
        else {
            this.drawText(ctx);
        }
    }

    drawText(ctx) {
        ctx.fillText("Wating for player", 100, 100);
    }

    drawButton(ctx) {
        if (this.state.active === true) {
            let passButton = new Image();
            let playButton = new Image();
            passButton.src = images_path["pass"];
            playButton.src = images_path["play"];
            passButton.onload = function () {
                ctx.drawImage(passButton, 500, 330, 70, 40);
                ctx.drawImage(playButton, 800, 330, 70, 40);
            }
        }
    }

    drawSelfCards(ctx) {
        let self_cards = this.state.self.cards;
        let self_start_x = 650 - self_cards.length / 2 * 50;
        let self_start_y = 400;
        let dx = 50;
        let i = 0;
        Promise.all(self_cards.map(x => this.loadImage(images_path[x])))
            .then((images) => images.forEach((image, i) => {
                if (this.state.selected_index.includes(i)) {
                    ctx.drawImage(image, self_start_x + i * dx, self_start_y - 10);
                }
                else {
                    ctx.drawImage(image, self_start_x + i * dx, self_start_y);
                }
                i++;
            })).catch((err) => { console.log("aa" + err + ";;;;;;"); });
        ctx.fillText(this.state.self.name, 650, 350);
        ctx.fillText(this.state.self.score, 680, 350);
    }

    drawSides(ctx) {

        let left_card_left = this.state.left.cards;
        let right_card_left = this.state.left.cards;
        let backImg = new Image();
        backImg.src = images_path["back"];
        ctx.fillText("Score: " + this.state.left.score, 0, 10);
        ctx.fillText("Name: " + this.state.left.name, 0, 20);
        ctx.fillText("Cards Left: " + left_card_left, 0, 40);
        ctx.fillText("Score: " + this.state.right.score, 1300, 10);
        ctx.fillText(this.state.right.name, 1300, 20);
        ctx.fillText("Cards Left: " + right_card_left, 1300, 30);
        backImg.onload = function () {
            ctx.drawImage(backImg, 0, 50, 100, 150);
            ctx.drawImage(backImg, 1300, 50, 100, 150);
        }
    }

    drawPreviousPlay(ctx) {
        if (this.state.previous_play.cards !== null) {
            let cards = this.state.previous_play.cards;
            if (this.state.previous_play.position === "left" || this.state.previous_play.position === "right") {

                let self_start_x = this.state.previous_play.position === "left" ? 150 : 1150;
                let self_start_y = 120;
                let dx = 50;
                let i = 0;
                Promise.all(cards.map(x => this.loadImage(images_path[x])))
                    .then((images) => images.forEach((image, i) => {
                        ctx.drawImage(image, self_start_x, self_start_y + i * dx);
                        i++;
                    })).catch((err) => { console.log("aa" + err + ";;;;;;"); });
            }
            if (this.state.previous_play.position === "self") {
                let self_start_x = 600;
                let self_start_y = 150;
                let dx = 50;
                let i = 0;
                Promise.all(cards.map(x => this.loadImage(images_path[x])))
                    .then((images) => images.forEach((image, i) => {
                        ctx.drawImage(image, self_start_x + i * dx, self_start_y);
                        i++;
                    })).catch((err) => { console.log("aa" + err + ";;;;;;"); });
            }
        }
    }

    drawLandlord(ctx) {
        switch (this.state.landlord) {
            case "left":
                ctx.fillText("landlord", 120, 250);
                break;
            case "right":
                ctx.fillText("landlord", 950, 250);
                break;
            case "self":
                ctx.fillText("landlord", 650, 380);
                break;
        }

    }


    onDown(event) {
        let self_start_x = 650 - this.state.self.cards.length / 2 * 50;
        let card_size = this.state.self.cards.length;
        let cx = event.pageX;
        let cy = event.pageY;
        if (cx >= self_start_x && cx <= self_start_x + 50 * (card_size + 1) && cy >= 400 && cy <= 565) {
            //alert((cx - self_start_x) / 50);
            let index = Math.floor((cx - self_start_x) / 50);
            if (index === card_size) {
                index = index - 1;
            }
            var new_index = Array.from(this.state.selected_index);
            if (new_index.includes(index)) {
                let i = new_index.indexOf(index);
                new_index.splice(i, 1);
            }
            else {
                new_index.push(index);
            }
            //console.log(new_index);
            let state1 = _.assign({}, this.state, { selected_index: new_index });
            this.setState(state1, () => console.log(this.state.selected_index));

        }

        if (cx >= 500 && cx <= 570 && cy >= 330 && cy <= 370) {
            alert("pass");
        }

        if (cx >= 800 && cx <= 870 && cy >= 330 && cy <= 370) {
            alert("paly");
        }

    }

    render() {
        /*if (this.state.phase !== "card_play") {
            return <p> Waiting For Players</p>
        }

        else {
            return <div>
                <canvas id="main" ref="canvas" width="1500" height="1000">
                </canvas>
            </div>

        }*/
        return <div>
            <canvas id="main" ref="canvas" width="1500" height="1000">
            </canvas>
        </div>
    }


}
