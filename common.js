(function(){
  var C=window.APP_CONFIG||{};
  var A={sb:null};
  A.configured=!!(C.SUPABASE_URL&&C.SUPABASE_ANON_KEY&&String(C.SUPABASE_URL).indexOf('PASTE')<0&&String(C.SUPABASE_ANON_KEY).indexOf('PASTE')<0);
  A.init=function(){
    if(!A.configured||!window.supabase)return false;
    A.sb=window.supabase.createClient(C.SUPABASE_URL,C.SUPABASE_ANON_KEY);
    return true;
  };
  A.esc=function(s){return String(s==null?'':s).replace(/[&<>"']/g,function(c){return {'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]})};
  A.err=function(e){
    var m=(e&&e.message)||String(e||'');
    if(/invalid login/i.test(m))return 'Email ya password galat hai.';
    if(/already (been )?registered/i.test(m))return 'Ye email pehle se registered hai. Login karein.';
    if(/not confirmed/i.test(m))return 'Pehle apna email confirm karein (inbox ya spam folder dekhein).';
    if(/rate limit|too many/i.test(m))return 'Bahut zyada koshish ho gayi. Thodi der baad try karein.';
    if(/password should|at least/i.test(m))return 'Password kam se kam 8 akshar ka rakhein.';
    if(/fetch|network/i.test(m))return 'Internet ya server ki dikkat hai. Dobara try karein.';
    return m||'Kuch gadbad hui. Dobara try karein.';
  };
  A.profile=async function(){
    var r=await A.sb.auth.getSession();
    var s=r&&r.data&&r.data.session;
    if(!s)return null;
    var p=await A.sb.from('profiles').select('*').eq('id',s.user.id).single();
    if(p.error||!p.data)return {id:s.user.id,email:s.user.email,status:'pending',role:'user',full_name:''};
    return p.data;
  };
  A.setupHtml='<div class="setup"><h2 style="margin-top:0;color:#1B6B34">Setup baaki hai</h2><p><code>config.js</code> file mein Supabase ka <b>URL</b> aur <b>anon key</b> paste karna hai. Poora tarika README mein diya hai.</p></div>';
  window.APP=A;
})();
