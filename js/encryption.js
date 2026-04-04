// written by toshi isogai 
// 2022

const re_enc = /<encrypt([^>]*?)>([\s\S]*?)<\/encrypt *>/mg;
const re_enc2 = /<encrypt([^>]*?)>([\s\S]*?)<\/encrypt *>/m;
const re_pass = / pass=('[^']*'|"[^"]*")/;
const re_remove = /<org_text[^>]*>.*?<\/org_text>/mg;
var g_art;

// encrypt <article> with <pass>
// return encrypted string of <article>
function encrypt (article, pass) {
    //var chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    //var pass = '';
    //for (var i = 0; i < 20; i++) {
    //    pass += chars.charAt(Math.floor(Math.random() * chars.length));
    //}

    var result;
    var text = (' ' + article).slice(1);
     //        console.log("encrypting text <" + text + ">");

    while (result = re_enc.exec(text)) {
        var block = result[0];
        var content = result[2];
        console.log("encrypting <" + content + ">");
        var encryptedAES = CryptoJS.AES.encrypt(content, pass);
        var ct = encryptedAES.ciphertext.toString(CryptoJS.enc.Base64);
        var iv = encryptedAES.iv.toString(CryptoJS.enc.Base64);
        var salt = encryptedAES.salt.toString(CryptoJS.enc.Base64);

        text = text.replace(block, 
                            '<p><decrypt><tri_code onclick="popup_dec_show()"> ct:<ct>' + ct + '</ct>&nbsp;&nbsp;iv:<iv>' + 
                            iv + '</iv>&nbsp;&nbsp;salt:<salt>' + salt + '</salt></tri_code>' +
                           '&nbsp;&nbsp;&nbsp;<org_text>&nbsp</org_text></decrypt></p>' + "\n");
    }
    return text;
}

// search "<encrypt>" tag in id_textarea_body 

function search_encrypt_tag () {
    var id_form_body = "id_form_body";
    var id_textarea_body = "id_textarea_body";
    var text;
    text = $('#' + id_textarea_body).summernote('code');

//    if (nic_editor.nicInstances.length == 0) {
//        text = document.getElementById(id_textarea_body).value;
//    } else {
//        var nic = nicEditors.findEditor(id_textarea_body);
 //       text = nic.getContent();
 //       text = text.replace(/&lt;([a-zA-Z\/])/gi,"<$1");
 //       text = text.replace(/&gt;/gi,">");
 //   }
    var result;
    var form = document.getElementById(id_form_body);
    console.log("form:" + form);

    text = text.replace(re_remove, "<org_text>&nbsp;</org_text>");  // filter out decripted text

    if (result = re_enc2.exec(text)) {
        var attr = result[1];
        var cont = result[2];
        if (result = re_pass.exec(attr)) {
            // passphrase embedded
            var pass = result[1].slice(1,-1);
            //console.log("passphrase embedded:" + pass);
            text = encrypt(text, pass);
            post_form(id_form_body, id_textarea_body, text);

        } else {
            // prompt passphrase
            popup_enc_show(id_form_body, id_textarea_body);
            
        }
    } else {
        post_form(id_form_body, id_textarea_body, text);
    }
}

function popup_enc_post(id_form_body,id_textarea_body) { 
    document.getElementById("popup_enc").style.display = "none";
    var pass = document.getElementById("pass").value;

    var body = document.getElementById(id_textarea_body).value;
    
    var text = encrypt(body, pass);

    var form = document.getElementById(id_form_body);

    post_form(id_form_body, id_textarea_body, text);


};

function popup_enc_cancel() { 
    document.getElementById("popup_enc").style.display = "none";
}

function popup_enc_show() {
     document.getElementById("popup_enc").style.display = "block";
}


function post_form(id_form, id_textarea, text, method='post') {

    var textarea = document.getElementById(id_textarea);
    var form = document.getElementById(id_form);
    $('#' + id_textarea).summernote('code', text);

    form.submit();
}


// decrypt messages in <decrypt> tags
function decrypt (pass) {

    var dec_tags = document.getElementsByTagName("decrypt");
    for( var ix=0; ix<dec_tags.length; ix++) {
        var dec = dec_tags[ix];
        var ct = dec.getElementsByTagName("ct");
        var iv = dec.getElementsByTagName("iv");
        var salt = dec.getElementsByTagName("salt");
        var encrypted = {ciphertext : CryptoJS.enc.Base64.parse(ct[0].innerText),
                         iv : CryptoJS.enc.Base64.parse(iv[0].innerText),
                         salt: CryptoJS.enc.Base64.parse(salt[0].innerText) };

        var decryptedBytes = CryptoJS.AES.decrypt(encrypted, pass);
        var plaintext = decryptedBytes.toString(CryptoJS.enc.Utf8);
        var org_text = dec.getElementsByTagName("org_text");
        org_text[0].outerHTML = '<org_text onclick="decrypt_undo()">' +  plaintext + '</org_text>';
    }
}

function decrypt_undo () {
    var org_text = document.getElementsByTagName("org_text");
    for( var ix=0; ix<org_text.length; ix++) {
        org_text[ix].innerHTML = '';
    }
}

function popup_dec_show() {
     document.getElementById("popup_dec").style.display = "block";
}

function popup_dec_cancel() {
     document.getElementById("popup_dec").style.display = "none";
}

function popup_dec_text() { 
    document.getElementById("popup_dec").style.display = "none";
    var pass = document.getElementById("pass").value;
    decrypt(pass);
};

