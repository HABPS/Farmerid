# Agri Record - Login + Admin Setup (Supabase + Vercel)

Is folder mein:
- index.html       = Card Maker (sirf login + approved user ko khulta hai)
- login.html       = Login page
- register.html    = Naya account (admin approve karega)
- reset.html       = Naya password (email link se)
- admin.html       = Admin Panel (users approve/block, card log, CSV)
- config.js        = Supabase URL + key yahan paste karni hai
- supabase-setup.sql = Database + security rules
- common.js, app.css, vercel.json, robots.txt

## Step 1: Supabase project banayein (free)
1. supabase.com par jaakar GitHub ya email se sign up karein.
2. "New project" dabayein. Naam kuch bhi, Database password likh kar rakh lein, Region: **Mumbai (ap-south-1)**.
3. Project ban jaye to **Project Settings -> API** mein ye do cheezein copy karein:
   - Project URL (https://xxxx.supabase.co)
   - anon public key (lambi key)

## Step 2: Database banayein
1. Supabase mein left menu: **SQL Editor -> New query**.
2. `supabase-setup.sql` ka poora text paste karke **Run** dabayein ("Success" aana chahiye).

## Step 3: Login settings
**Authentication -> Providers -> Email**:
- "Confirm email" band (OFF) rakhna sabse aasan hai, taaki registration ke baad email confirm na karna pade.
  (Admin approval to phir bhi lagega.) ON rakhein to user ko email confirm karna padega.

**Authentication -> URL Configuration**:
- Site URL: aapka Vercel link, jaise https://aapka-naam.vercel.app
- Redirect URLs mein bhi wahi link + /reset.html aur /login.html daal dein.

## Step 4: config.js bharein
`config.js` kholein aur PASTE... wali dono jagah Step 1 ki value daalein. Save karein.

## Step 5: GitHub par update aur deploy
Saari files (index.html, login.html, register.html, reset.html, admin.html, config.js, common.js, app.css, vercel.json, robots.txt) GitHub repository mein upload karein (purani files replace ho jayengi). `supabase-setup.sql` aur `README.md` upload karna zaroori nahi.
Vercel apne aap dobara deploy kar dega.

## Step 6: Pehla admin banayein
1. Site par `/register.html` se apna account banayein.
2. Supabase -> SQL Editor mein ye chalayein (apni email likh kar):

    update public.profiles set role = 'admin', status = 'approved' where email = 'AAPKI-EMAIL@example.com';

3. Ab `/login.html` se login karein. Card Maker khulega aur upar "Admin Panel" ka link dikhega.

## Roz ka kaam
- Naya banda register kare -> Admin Panel -> Users -> **Approve** dabayein.
- Kisi ko rokna ho -> **Block**.
- Kaun kitne card bana raha hai -> **Card log** tab, CSV mein download bhi hota hai.

## Zaroori suraksha baatein
- Card log mein Aadhaar number kabhi save nahi hota. Sirf Farmer ID, naam, mobile, type aur time.
- Login ki security Supabase sambhalta hai. Users ka data sirf admin dekh sakta hai (RLS rules).
- Card Maker ka page khud sirf HTML hai: koi technical vyakti login ke bina uski source file dekh sakta hai, par usme koi secret ya customer data nahi hai. Customer ka data sirf browser mein rehta hai.
- `anon key` public hoti hai, usse dikkat nahi. **service_role key kabhi config.js ya GitHub par na daalein.**
- Kisi par bharosa na ho to use admin na banayein: admin sab users ke card log dekh sakta hai.
