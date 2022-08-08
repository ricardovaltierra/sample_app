// Menu manipulation

// Adds a toggle listener.
function addToggleListener(selected_id, menu_id, toggle_class) {
  let clickedElement = document.querySelector(`#${selected_id}`);
  clickedElement.addEventListener("click", function(event) {
    event.preventDefault();
    let menu = document.querySelector(`#${menu_id}`);
    menu.classList.toggle(toggle_class);
  });
}

// Add toggle listeners to listen for clicks.
document.addEventListener("turbo:load", function() {
  addToggleListener("hamburger", "navbar-menu", "collapse");
  addToggleListener("account", "dropdown-menu", "active");
});