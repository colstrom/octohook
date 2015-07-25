var api = fermata.json(document.location.origin);

function icon(name) {
  "use strict";
  var element = document.createElement("span");
  element.className = "octicon octicon-" + name;
  return element;
}

function componentName(name) {
  "use strict";
  return name.replace(/^src\/(services\/)?/, "").replace(/_ng$/, "").replace(/_/, " ");
}

function addToChangelog(path) {
  "use strict";
  var item = document.createElement("button");
  item.appendChild(icon("package"));
  item.appendChild(document.createTextNode(" " + componentName(path)));
  document.getElementById("changelog").appendChild(item);
}

function emptyChangeLog() {
  "use strict";
  var changelog = document.getElementById("changelog");
  while(changelog.firstChild) {
    changelog.removeChild(changelog.firstChild);
  }
}

function replaceChangelog(changes) {
  "use strict";
  emptyChangeLog();
  for (var index in changes) {
    addToChangelog(changes[index]);
  }
}

document.getElementById("get-changed-components").onclick = function () {
  "use strict";
  var base = document.getElementById("base-commit").value || document.getElementById("base-commit").placeholder;
  var head = document.getElementById("head-commit").value || document.getElementById("head-commit").placeholder;
  api("changes")(head)(base).get(function (error, changes) {
    replaceChangelog(changes);
  });
};
