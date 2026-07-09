const supported = ["ja", "en", "zh"];
const initial = (() => {
  const saved = localStorage.getItem("siteLanguage");
  if (supported.includes(saved)) return saved;
  const browser = (navigator.language || "en").toLowerCase();
  if (browser.startsWith("ja")) return "ja";
  if (browser.startsWith("zh")) return "zh";
  return "en";
})();

function setLanguage(language) {
  const value = supported.includes(language) ? language : "en";
  localStorage.setItem("siteLanguage", value);
  document.documentElement.lang = value === "zh" ? "zh-Hans" : value;
  document.querySelectorAll("[data-lang]").forEach((node) => {
    node.classList.toggle("active", node.dataset.lang === value);
  });
  document.querySelectorAll("[data-language-button]").forEach((button) => {
    button.setAttribute("aria-pressed", button.dataset.languageButton === value ? "true" : "false");
  });
}

document.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("[data-language-button]").forEach((button) => {
    button.addEventListener("click", () => setLanguage(button.dataset.languageButton));
  });
  setLanguage(initial);
});

