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
            phase: "waiting_for_players",
            landlord: null,
            left: {
                name: null,
                points: 0,
                cards: [],
            },
            right: {
                name: null,
                points: 0,
                cards: [],
            },
            self: {
                name: null,
                points: 0,
                cards: [],
            },
            active: false,
            previous_play: { position: null, cards: [] },
            selected_index: [],
            message: "",
            left_over_cards: null
        };

        this.channel
            .join()
            .receive("ok", this.got_view.bind(this))
            .receive("error", resp => {
                console.log("Unable to join", resp);
            });

        this.channel.on("player_joined", this.got_view.bind(this));
        this.channel.on("landlord_called", this.got_view.bind(this));
        this.channel.on("player_played", this.got_view.bind(this));
        this.channel.on("player_passed", this.got_view.bind(this));
        this.channel.on("landlord_passed", this.got_view.bind(this));
        this.channel.on("new_round", this.got_view.bind(this));
        this.channel.on("new_msg", payload => {
            this.state.message += "\n" + `[${Date()}] ${payload.body}`;
            this.updateChatRoom();
        });
        this.channel.on("show_left_over", payload => {
            const ctx = this.refs.canvas.getContext('2d');
            this.drawCardsLeftForEveryOne(ctx);});

    }

    componentDidMount() {

        this.refs.canvas.addEventListener("mousedown", this.onDown.bind(this), false);
        const ctx = this.refs.canvas.getContext('2d');
        ctx.font = "20px Comic Sans MS";
        this.updateCanvas(ctx);

    }

    componentDidUpdate(prevProps, prevState) {
        if (!(prevState === this.state)) {
            const ctx = this.refs.canvas.getContext('2d');
            ctx.font = "20px Comic Sans MS";
            ctx.clearRect(0, 0, 1500, 1000);
            this.updateCanvas(ctx);
        }

    }

    got_view(view) {
        if (view.game !== null) {
            this.setState(view.game, () => this.state.selected_index = []);
        }
    }

    get_winner(res) {
        if (res.winner) {
            const ctx = this.refs.canvas.getContext('2d');
            ctx.clearRect(0, 0, 1500, 1000);
            this.drawRestartButton(ctx);
        }
    }

    loadImage(images_path) {
        return new Promise((resolve, reject) => {
            let image = new Image();
            image.addEventListener("load", () => {
                resolve(image)
            });
            image.addEventListener("error", (err) => {
                reject(err)
            });
            image.src = images_path;
        });
    }

    updateCanvas(ctx) {
        if (this.state.phase === "call_landlord") {
            this.drawSides(ctx);
            this.drawSelfCards(ctx);
            this.drawCallLandordButton(ctx);
            this.drawCardsLeft(ctx);
        }
        else if (this.state.phase === "card_play") {
            this.drawSides(ctx);
            this.drawPreviousPlay(ctx);
            this.drawSelfCards(ctx);
            this.drawButton(ctx);
        }
        else {
            this.drawText(ctx);
        }
    }

    drawText(ctx) {
        ctx.font = "30px Comic Sans MS";
        let message = "Waiting for players to join, game will start when more than 2 people join this table...";
        ctx.fillText(message, 100, 100);
    }

    drawCardsLeft(ctx) {
        if (typeof (this.state.left.cards) === "number") {
            let backImg = new Image();

            backImg.src = images_path["back"];
            backImg.onload = function () {
                ctx.drawImage(backImg, 530, 100, 100, 150);
                ctx.drawImage(backImg, 640, 100, 100, 150);
                ctx.drawImage(backImg, 750, 100, 100, 150);
            };
        }
        else {
            let leftover_cards = this.state.left_over_cards;
            let dx = 110;
            let i = 0;
            Promise.all(leftover_cards.map(x => this.loadImage(images_path[x])))
                .then((images) => images.forEach((image, i) => {
                    ctx.drawImage(image, 530 + i * dx, 100);
                    i++;
                })).catch((err) => {
                    console.log(err);
                });

        }
    }

    drawCardsLeftForEveryOne(ctx) {
        let leftover_cards = this.state.left_over_cards;
        let dx = 110;
        let i = 0;
        Promise.all(leftover_cards.map(x => this.loadImage(images_path[x])))
            .then((images) => images.forEach((image, i) => {
                ctx.drawImage(image, 530 + i * dx, 100);
                i++;
            })).catch((err) => {
                console.log(err);
            });
    }

    drawCallLandordButton(ctx) {
        if (this.state.active === true) {
            let callButton = new Image();
            let passButton = new Image();
            callButton.src = images_path["call"];
            passButton.src = images_path["pass"];
            passButton.onload = function () {
                ctx.drawImage(passButton, 500, 600, 70, 40);
            };
            callButton.onload = function () {
                ctx.drawImage(callButton, 800, 600, 70, 40);
            }
        }
    }

    drawButton(ctx) {
        if (this.state.active === true) {
            if (this.state.self.cards.length !== 0) {
                let passButton = new Image();
                let playButton = new Image();
                passButton.src = images_path["pass"];
                playButton.src = images_path["play"];
                passButton.onload = function () {
                    ctx.drawImage(passButton, 500, 600, 70, 40);
                };
                playButton.onload = function () {
                    ctx.drawImage(playButton, 800, 600, 70, 40);
                }
            } else {
                this.drawRestartButton(ctx);
            }
        }
    }

    drawSelfCards(ctx) {
        let self_cards = this.state.self.cards;
        let self_start_x = 650 - self_cards.length / 2 * 50;
        let self_start_y = 700;
        let dx = 50;
        let i = 0;
        Promise.all(self_cards.map(x => this.loadImage(images_path[x])))
            .then((images) => images.forEach((image, i) => {
                if (this.state.selected_index.includes(i)) {
                    ctx.drawImage(image, self_start_x + i * dx, self_start_y - 10);
                } else {
                    ctx.drawImage(image, self_start_x + i * dx, self_start_y);
                }
                i++;
            })).catch((err) => {
                console.log(err);
            });
        ctx.fillText("Name: " + this.state.self.name, 500, 680);
        ctx.fillText("Score: " + this.state.self.points, 650, 680);
        if (this.state.phase === "card_play") {
            if (this.state.landlord === "self") {
                ctx.fillText("landlord", 800, 680);
            } else {
                ctx.fillText("peasant", 800, 680);
            }
        }
    }

    drawSides(ctx) {
        let dy = 20;
        let observer_dy = 30;
        let j = 0, k = 0;
        let backImg = new Image();
        let backImg1 = new Image();
        backImg.src = images_path["back"];
        backImg1.src = images_path["back"];
        if (this.state.left.cards !== null) {
            let left_card_left = this.state.left.cards;
            if (typeof (this.state.left.cards) === "number") {
                backImg1.onload = function () {
                    for (let i = 0; i < left_card_left; i++) {
                        ctx.drawImage(backImg1, 10, 80 + i * dy, 100, 150);
                    }
                }
            } else {
                Promise.all(left_card_left.map(x => this.loadImage(images_path[x])))
                    .then((images) => images.forEach((image, j) => {
                        ctx.drawImage(image, 10, 80 + j * observer_dy);
                        j++;
                    })).catch((err) => {
                        console.log(err);
                    });
            }
        }
        ctx.fillText("Score: " + this.state.left.points, 0, 15);
        ctx.fillText("Name: " + this.state.left.name, 0, 40);
        if (this.state.phase === "card_play") {
            if (this.state.landlord === "left") {
                ctx.fillText("landlord", 0, 65);
            } else {
                ctx.fillText("peasant", 0, 65);
            }
        }

        if (this.state.right.cards !== null) {
            let right_card_left = this.state.right.cards;
            if (typeof (this.state.right.cards) === "number") {
                backImg.onload = function () {
                    for (let i = 0; i < right_card_left; i++) {
                        ctx.drawImage(backImg, 1350, 80 + i * dy, 100, 150);
                    }
                }
            } else {
                Promise.all(right_card_left.map(x => this.loadImage(images_path[x])))
                    .then((images) => images.forEach((image, k) => {
                        ctx.drawImage(image, 1350, 80 + k * observer_dy);
                        k++;
                    })).catch((err) => {
                        console.log(err);
                    });
            }
        }
        ctx.fillText("Score: " + this.state.right.points, 1350, 15);
        ctx.fillText("Name: " + this.state.right.name, 1350, 40);
        if (this.state.phase === "card_play") {
            if (this.state.landlord === "right") {
                ctx.fillText("landlord", 1350, 65);
            } else {
                ctx.fillText("peasant", 1350, 65);
            }
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
                    })).catch((err) => {
                        console.log(err);
                    });
            }
            if (this.state.previous_play.position === "self") {
                let self_start_x = 600;
                let self_start_y = 420;
                let dx = 50;
                let i = 0;
                Promise.all(cards.map(x => this.loadImage(images_path[x])))
                    .then((images) => images.forEach((image, i) => {
                        ctx.drawImage(image, self_start_x + i * dx, self_start_y);
                        i++;
                    })).catch((err) => {
                        console.log(err);
                    });
            }
        }
    }

    drawRestartButton(ctx) {
        ctx.clearRect(500, 700, 70, 40);
        let restartImg = new Image();
        restartImg.src = images_path["restart"];
        restartImg.onload = function () {
            ctx.drawImage(restartImg, 600, 600, 70, 40);
        };
    }


    onDown(event) {
        let self_start_x = 650 - this.state.self.cards.length / 2 * 50;
        let card_size = this.state.self.cards.length;
        let cx = event.pageX;
        let cy = event.pageY;
        console.log(cx, cy);
        if (cx >= self_start_x && cx <= self_start_x + 50 * (card_size + 1) && cy >= 700 && cy <= 865) {
            let index = Math.floor((cx - self_start_x) / 50);
            if (index === card_size) {
                index = index - 1;
            }
            let new_index = Array.from(this.state.selected_index);
            if (new_index.includes(index)) {
                let i = new_index.indexOf(index);
                new_index.splice(i, 1);
            } else {
                new_index.push(index);
            }
            let state1 = _.assign({}, this.state, { selected_index: new_index });
            this.setState(state1);

        }

        if (cx >= 500 && cx <= 580 && cy >= 600 && cy <= 660) {
            if (this.state.active && this.state.self.cards.length !== 0 && this.state.phase === "card_play") {
                this.channel.push("pass", {})
                    .receive("ok", this.got_view.bind(this));
            }
            if (this.state.active && this.state.phase === "call_landlord") {
                this.channel.push("pass_landlord", {}).receive("ok", this.got_view.bind(this));
            }
        }

        if (cx >= 800 && cx <= 875 && cy >= 620 && cy <= 660) {
            if (this.state.active && this.state.self.cards.length !== 0 && this.state.phase === "card_play") {
                this.state.selected_index.sort((a, b) => {
                    return a - b
                });
                this.channel.push("play_cards", { card_indexes: this.state.selected_index })
                    .receive("ok", this.got_view.bind(this));

                this.channel.push("who_wins", {}).receive("ok", this.get_winner.bind(this));
            }

            if (this.state.active && this.state.phase === "call_landlord") {
                this.channel.push("show_left_over", {});
                window.setTimeout(() => {
                    this.channel.push("call_landlord", {}).receive("ok", this.got_view.bind(this));}, 3000
                    );
                
            }
        }

        if (cx >= 600 && cx <= 680 && cy >= 600 && cy <= 657) {
            if (this.state.self.cards.length === 0) {
                this.channel.push("start_new_round", {}).receive("ok", this.got_view.bind(this));
            }
        }
    }

    sendText() {
        this.channel.push("new_msg", { body: window.user_name + ": " + document.getElementById("textInput").value });
    }

    updateChatRoom() {
        document.getElementById("textInput").value = "";
        document.getElementById("chatBoard").value = this.state.message;
    }

    render() {
        return (<div>
            <canvas id="main" ref="canvas" width="1500" height="1000">
            </canvas>
            <ChatBoard phase={this.state.phase} />
            <TextInput phase={this.state.phase} />
            <SendButton phase={this.state.phase} onSendClick={() => this.sendText()} />
        </div>)
    }
}

function ChatBoard(props) {
    let { phase } = props;
    if (phase === "card_play") {
        return (<div className="textClass">
            <textarea id="chatBoard" readOnly></textarea>
        </div>)
    }
    return null;
}


function SendButton(props) {
    let { phase, onSendClick } = props;
    if (phase === "card_play") {
        return (<div className="userInput">
            <p>
                <button id="sendButton" onClick={onSendClick}>Send</button>
            </p>
        </div>)
    }
    return null;

}

function TextInput(props) {
    let { phase } = props;
    if (phase === "card_play") {
        return (<p><input id="textInput" size="35"></input></p>)
    }
    return null;
}
