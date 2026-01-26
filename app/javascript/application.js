// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
import "../stylesheets/application"
import "@rails/ujs" 

document.addEventListener("turbo:load", () => {
  const slides = document.querySelector(".slides");
  const slideElements = document.querySelectorAll(".slide");
  const nextBtn = document.querySelector(".next");
  const prevBtn = document.querySelector(".prev");

  if (!slides || slideElements.length === 0) return;

  let index = 0;
  const slideCount = slideElements.length;

  nextBtn?.addEventListener("click", () => move(1));
  prevBtn?.addEventListener("click", () => move(-1));

  function move(step) {
    index = (index + step + slideCount) % slideCount;
    slides.style.transform = `translateX(-${index * 100}%)`;
  }

  setInterval(() => move(1),2000);
});