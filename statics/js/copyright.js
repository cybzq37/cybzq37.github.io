document$.subscribe(() => {
    const year = new Date().getFullYear();
    const startYear = 2021;
    const author = "Your Name";
  
    const range = year > startYear ? `${startYear}–${year}` : `${year}`;
    const text = `© ${range} ${author}. All rights reserved.`;
  
    const el = document.getElementById("copyright");
    if (el) el.innerText = text;
  });
  