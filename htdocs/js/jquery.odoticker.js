(function($){
	$.fn.odoTicker=function(options){
		var element=this;
		var defaults={number:99999,height:28,speed:1500};
		var options=$.extend(defaults,options);
		$(element).each(function(){
			element.addClass('odoTicker');
			loadTicker();
			function loadTicker(){
				var ticnum=options.number;
				var fticnum=addCommas(ticnum);
				addTicker(fticnum);
				if(ticnum&&ticnum!=0){
					var s=String(fticnum);
					for(i=s.length;i>=0;i--){
						var onum=s.charAt(i);
						element.children("div[rel='num"+i+"']").attr('value',onum)
					}
					element.children('.odoNumber').each(function(){
						var nval=$(this).attr('value');
						if(!isNaN(nval)){
							var nheight=Number(nval)*options.height*-1;
							$(this).animate({top:nheight+'px'},options.speed)
						}
						if(nval==','){
							$(this).animate({top:'-280px'},options.speed)
						}
					})
				}
			};
			function addTicker(newnum){
				var digitcnt=element.children(".odoNumber").size();
				var nnum=String(newnum).length;
				var digitdiff=Number(nnum-Number(digitcnt));
				if(digitdiff<0){
					var ltdig=(Number(nnum)-1);
					element.children(".odoNumber:gt("+ltdig+")").remove()
				}
				for(i=1;i<=digitdiff;i++){
					element.append('<div class="odoNumber" rel="num'+(Number(digitcnt+i-1))+'">&nbsp;</div>')
				}
			}
			function addCommas(nStr){
				nStr+='';x=nStr.split('.');x1=x[0];x2=x.length>1?'.'+x[1]:'';var rgx=/(\d+)(\d{3})/;while(rgx.test(x1)){x1=x1.replace(rgx,'$1'+','+'$2')}return x1+x2
			}
		})
	}
})(jQuery);
