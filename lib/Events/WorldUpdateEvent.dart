part of FinalEarthCrawler;

class WorldUpdateEvent extends FinalEarthEvent {
  final World world;
  final World previousWorld;

  WorldUpdateEvent (World this.world, World this.previousWorld) {

  }
  
}