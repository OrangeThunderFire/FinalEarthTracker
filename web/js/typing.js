function DisplayConsole (element) {
    this.element = element;
}

DisplayConsole.prototype.log = function (displayConsoleBuilder) {
    var li = document.createElement("li");
    li.className = "typed";
    if (displayConsoleBuilder instanceof DisplayConsoleBuilder) {
        displayConsoleBuilder.appendTo(li);
    }
    else {
        li.innerText = displayConsoleBuilder + "";
    }
    console.log(li.innerText);
    jQuery(li).delay(10000).fadeOut(600, function () {
        $(li).remove();
    });
    this.element.appendChild(li);
};
DisplayConsole.prototype.builder = function () {
    return new DisplayConsoleBuilder();
}

function DisplayConsoleClass (className, message) {
    this.className = className;
    this.message = message;
}

DisplayConsoleClass.prototype.appendTo = function (element) {
    var span = document.createElement("span");
    span.className = this.className;
    span.innerText = this.message;
    element.appendChild(span);
};

function DisplayConsoleBuilder () {
    this.parts = [];
    this.write("["+moment().format("hh:mm:ss")+"] ", "timestamp");
}


DisplayConsoleBuilder.prototype._writeClass = function (message, className) {
    this.parts.push(new DisplayConsoleClass(className, message));
    return this;
};

DisplayConsoleBuilder.prototype.appendTo = function (element) {
    this.parts.forEach(function (part) {
        part.appendTo(element);
    });
}
DisplayConsoleBuilder.prototype.write = function (message, className) {
    if (className != null) {
        return this._writeClass(message, className);
    }
    this.parts.push(new DisplayConsoleClass("", message));
    return this;
}
