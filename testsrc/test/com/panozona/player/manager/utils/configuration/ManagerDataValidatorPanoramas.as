package test.com.panozona.player.manager.utils.configuration{
	
	import com.panozona.player.component.*;
	import com.panozona.player.manager.data.*;
	import com.panozona.player.manager.data.actions.*;
	import com.panozona.player.manager.data.panoramas.*;
	import com.panozona.player.manager.events.*;
	import com.panozona.player.manager.utils.configuration.*;
	import com.robertpenner.easing.*;
	import flash.events.*;
	import flexunit.framework.*;
	import org.hamcrest.*;
	
	public class ManagerDataValidatorPanoramas extends com.panozona.player.manager.utils.configuration.ManagerDataValidator{
		
		protected var infoCount:int;
		protected var warningCount:int;
		protected var errorCount:int;
		
		protected var managerData:ManagerData;
		
		public function ManagerDataValidatorPanoramas():void {
			addEventListener(ConfigurationEvent.INFO, function(event:Event):void {infoCount++;});
			addEventListener(ConfigurationEvent.WARNING, function(event:Event):void{warningCount++;});
			addEventListener(ConfigurationEvent.ERROR, function(event:Event):void{errorCount++;});
		}
		
		[Before]
		public function beforeTest():void {
			infoCount = 0;
			warningCount = 0;
			errorCount = 0;
			
			managerData = new ManagerData();
		}
		
		[Test]
		public function repeatingPanoramaId():void {
			managerData.panoramasData.push(new PanoramaData("a","patha"));
			managerData.panoramasData.push(new PanoramaData("a","patha"));
			
			validate(managerData);
			
			Assert.assertEquals(0, infoCount);
			Assert.assertEquals(1, warningCount);
			Assert.assertEquals(0, errorCount);
		}
		
		[Test]
		public function panoramaNullPath():void {
			managerData.panoramasData.push(new PanoramaData(null, "path"));
			validate(managerData);
			
			Assert.assertEquals(0, infoCount);
			Assert.assertEquals(0, warningCount);
			Assert.assertEquals(1, errorCount);
		}
		
		[Test]
		public function panoramaSimpleActionTrigger():void {
			managerData.panoramasData.push(new PanoramaData("a", "patha"));
			managerData.panoramasData[0].onEnter = "nonexistantActionId";
			
			validate(managerData);
			
			Assert.assertEquals(0, infoCount);
			Assert.assertEquals(0, warningCount);
			Assert.assertEquals(1, errorCount);
		}
		
		[Test]
		public function panoramaComplexActionTrigger():void {
			managerData.panoramasData.push(new PanoramaData("pano_a", "path_a"));
			managerData.panoramasData.push(new PanoramaData("pano_b", "path_b"));
			managerData.panoramasData.push(new PanoramaData("pano_c", "path_c"));
			managerData.panoramasData.push(new PanoramaData("pano_d", "path_d"));
			
			managerData.actionsData.push(new ActionData("act_1"));
			managerData.actionsData.push(new ActionData("act_2"));
			managerData.actionsData.push(new ActionData("act_3"));
			managerData.actionsData.push(new ActionData("act_4"));
			
			// correct data 
			managerData.panoramasData[0].onEnterFrom.pano_b = "act_2";
			managerData.panoramasData[0].onEnterFrom.pano_c = "act_3";
			managerData.panoramasData[0].onEnterFrom.pano_d = "act_4";
			
			// warning same panorama id
			managerData.panoramasData[1].onEnterFrom.pano_b = "act_4";
			
			// warning nonexistant panorama id
			managerData.panoramasData[2].onEnterFrom.pano_nonexistant = "act_2";
			
			// warning nonexistant action id
			managerData.panoramasData[3].onEnterFrom.pano_a = "act_nonexistant";
			
			validate(managerData);
			
			Assert.assertEquals(0, infoCount);
			Assert.assertEquals(1, warningCount);
			Assert.assertEquals(2, errorCount);
		}
		
		[Test]
		public function repeatingHotspotSamePanorama():void {
			managerData.panoramasData.push(new PanoramaData("a", "patha"));
			
			managerData.panoramasData[0].hotspotsDataImage.push(new HotspotDataImage("h2","path2"));
			managerData.panoramasData[0].hotspotsDataImage.push(new HotspotDataImage("h2","path3"));
			
			validate(managerData);
			
			Assert.assertEquals(0, infoCount);
			Assert.assertEquals(1, warningCount);
			Assert.assertEquals(0, errorCount);
		}
		
		[Test]
		public function repeatingHotspotDifferentPanorama():void {
			managerData.panoramasData.push(new PanoramaData("a", "patha"));
			managerData.panoramasData.push(new PanoramaData("b", "pathb"));
			
			managerData.panoramasData[0].hotspotsDataImage.push(new HotspotDataImage("h1","path1"));
			managerData.panoramasData[0].hotspotsDataImage.push(new HotspotDataImage("h2","path2"));
			
			managerData.panoramasData[1].hotspotsDataImage.push(new HotspotDataImage("h2","path3"));
			managerData.panoramasData[1].hotspotsDataImage.push(new HotspotDataImage("h3","path4"));
			
			validate(managerData);
			
			Assert.assertEquals(0, infoCount);
			Assert.assertEquals(0, warningCount);
			Assert.assertEquals(0, errorCount); //TODO: really ?
		}
		
		[Test]
		public function hotspotMouse():void {
			managerData.actionsData.push(new ActionData("act_1"));
			managerData.actionsData.push(new ActionData("act_2"));
			managerData.actionsData.push(new ActionData("act_3"));
			managerData.actionsData.push(new ActionData("act_4"));
			
			managerData.panoramasData.push(new PanoramaData("a", "patha"));
			managerData.panoramasData[0].hotspotsDataImage.push(new HotspotDataImage("h1", "path1"));
			managerData.panoramasData[0].hotspotsDataImage[0].mouse.onClick = "act_1";
			managerData.panoramasData[0].hotspotsDataImage[0].mouse.onOut = "act_2";
			managerData.panoramasData[0].hotspotsDataImage[0].mouse.onOver = "act_3";
			managerData.panoramasData[0].hotspotsDataImage[0].mouse.onPress = "act_4";
			managerData.panoramasData[0].hotspotsDataImage[0].mouse.onRelease = "act_nonexistant";
			
			validate(managerData);
			
			Assert.assertEquals(0, infoCount);
			Assert.assertEquals(0, warningCount);
			Assert.assertEquals(1, errorCount);
		}
	}
}