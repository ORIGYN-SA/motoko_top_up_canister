import icpTopuper from 'ic:canisters/icpTopuper';

icpTopuper.greet(window.prompt("Enter your name:")).then(greeting => {
  window.alert(greeting);
});
