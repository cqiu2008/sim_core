//Global Assigment
var numStream = 0;

//Const Assigment
// ��2��ʼ����Ϊ0�У���ͷ��1:���صĸ����У�2����������
var constOrgTrNum = 2;
// td0 -- stream num  
// td1 -- stream type selections  
// td2 -- detail show 
// td3 -- L2 Common packet equal with 3+0 
// td4 -- L2 1588 packet equal with 3+1 
var constOrgTdNum= 3; 

//add one row in the current table
function addInstanceRow(tableId) {
	var tableObj = getTargetControl(tableId);
	var tbodyOnlineEdit = getTableTbody(tableObj);
	var theadOnlineEdit = tableObj.getElementsByTagName("tbody")[0];
	var elm = theadOnlineEdit.rows[theadOnlineEdit.rows.length - 1].cloneNode(true);
	numStream++;
	elm.style.display = "";
	elm.cells[0].innerHTML = numStream;
	tbodyOnlineEdit.appendChild(elm);
}

//�õ�table�е�tbody�ؼ���ע�����firefox
function getTableTbody(tableObj) {
	var tbodyOnlineEdit = tableObj.getElementsByTagName("tbody")[0];
	if (typeof (tbodyOnlineEdit) == "undefined" || tbodyOnlineEdit == null) {
		tbodyOnlineEdit = document.createElement("tbody");
		tableObj.appendChild(tbodyOnlineEdit);
	}
	return tbodyOnlineEdit;
}

//ɾ�������¼��ؼ����ڵ���
function deleteThisRow(targetControl) {
	if (targetControl.tagName == "TR")
		targetControl.parentNode.removeChild(targetControl);
	else
		deleteThisRow(targetControl.parentNode);
}

//ɾ�����ؼ����ڵ���
function deleteEndRow(ethPckTable) {
	var tableObj = document.getElementById(ethPckTable);
	var theadOnlineEdit = tableObj.getElementsByTagName("tbody")[0];
	var rowCur = theadOnlineEdit.rows[parseInt(numStream) + 1];
	if ((rowCur.tagName == "TR") && (parseInt(numStream) > 0)) {
		rowCur.parentNode.removeChild(rowCur);
	}
	else {
		alert("error when try to delete the last Row");
	}
	numStream--;
}

//show the detail message
function detailShow(selfOwn) {
	//(1) Judge whether is the detail header
	if (matchString("detail", selfOwn.innerHTML) == true) {
		var trObj = selfOwn.parentNode;
	}
	else {
		var trObj = selfOwn.parentNode.parentNode.parentNode;
	}
	//(2) ��ȡ��ǰ��ѡ���ţ����� [1] L2 1588,��ô��ȡ���Ϊ1
	var td1Obj = trObj.cells[1];
	var td1SelectObj = filterTextChildNodes(td1Obj);
	var re = /\d+\s*\]/; //ͨ��� ����] ������ʽ
	var arr = re.exec(td1SelectObj.value);
	var optValue = arr[0].replace(/\s*\]/g, "");
	//(3)��ȡ��ǰҪ��ʾ��td����
	var j = constOrgTdNum + parseInt(optValue);
	// tr's child ,means cells
	var tdCurObj = trObj.cells[j];
	//(4)�ر�����֮ǰ�򿪵�td����,���˵�ǰ�����td
	for (var i = constOrgTdNum; i < trObj.cells.length; i++) {
		if (i != j)
			trObj.cells[i].style.display = 'none';
	}
	//(5)���֮ǰû�򿪣��ʹ��������֮ǰ���˾͹ر���
	if (tdCurObj.style.display == 'none') {
		tdCurObj.style.display = '';
		trObj.cells[0].bgColor = "#D8D8BF";//����ɫ
		trObj.cells[1].bgColor = "#D8D8BF";//����ɫ
		trObj.cells[2].bgColor = "#D8D8BF";//����ɫ
	}
	else {
		tdCurObj.style.display = 'none';
		trObj.cells[2].style.display = ''; //��detail
	}
}

//display the public table
function publicTableShow(ethPublicPckTableId) {
	tableObj = getTargetControl(ethPublicPckTableId);
	var tableRow = tableObj.getElementsByTagName('tr');
	for (var i = 1; i < tableRow.length; i++) {
		if (tableRow[i].style.display == '') //if it was opened ,then ,closed it
			tableRow[i].style.display = 'none';
		else
			tableRow[i].style.display = '';
	}
}

//just test
function show(value) {
//	alert(value);
}

// ����firefox���ԣ����˵����к�ע�͵ȵ���Ϣ
function filterTextChildNodes(parentNodeCur) {
	var i = 0;
	while ((parentNodeCur.childNodes[i].nodeName == "#text") ||
		(parentNodeCur.childNodes[i].nodeName == "#comment")
	) {
		i++;
	}
	return parentNodeCur.childNodes[i];
}

//�õ�ָ���Ŀؼ�
//���紫�ݵ��ǿؼ����÷��ؿؼ�
//���紫�ݵ���IDֵ�����Զ����ҳ��ؼ�������
function getTargetControl(targetControl) {
	if (typeof (targetControl) == "string") {
		return document.getElementById(targetControl);
	}
	else return targetControl;
}

//ȥ���ո�
function Trim(s) {
	var m = s.match(/^\s*(\S+(\s+\S+)*)\s*$/);
	return (m == null) ? "" : m[1];
}

// check public table
function publicTableCheck(ethPublicPckTableId) {
	tableObj = getTargetControl(ethPublicPckTableId);
	var tableRow = tableObj.getElementsByTagName('tr');
	var valueTmp = filterTextChildNodes(tableRow[1].cells[2]);
	//ȥ���ո�
	valueTmp.value = Trim(valueTmp.value);
	//�ж��Ƿ���10������
	decimalCheck(valueTmp.value);
	//ת����16����
	var decValue = parseInt(valueTmp.value);
	decValue = decValue.toString(16);
	decValue1 = transformHexBytes(4, decValue);
}

////��16������ת�����ֽ���ʽ
////���� 0x123,���ת����4Byte����Ϊ00 00 01 23
function transformHexBytes(numBytes, valueHexInput) {
	var valueHexInputLength = valueHexInput.length;
	var numBytesDouble = numBytes * 2;
	if (valueHexInputLength > numBytesDouble) {
		alert("numBytes too small or HexInput too big");
		return 0;
	}
	else {
		////(1)�������ַ�����λ��0����
		////����ԭ����0x13f,��Ҫ4BYTE�������0000013f
		var valueHexArr1 = new Array();
		var j = 0;
		for (var i = 0; i < numBytesDouble; i++) {
			if (i < (numBytesDouble - valueHexInputLength)) {
				valueHexArr1[i] = "0";
			}
			else {
				valueHexArr1[i] = valueHexInput[j];
				j++;
			}
		}
		////(2)�ֽ�֮���ÿո�ֿ�
		////����ԭ����0000013f �ֿ����Ϊ00 00 01 3f
		var valueHexOutputLength = numBytes * 3;
		var valueHexArr2 = new Array();
		var k = 0;
		var j = 0;
		for (var i = 0; i < valueHexOutputLength; i++) {
			if (j == 2) {
				valueHexArr2[i] = ' ';
				j = 0;
			}
			else {
				valueHexArr2[i] = valueHexArr1[k];
				k++;
				j++;
			}
		}
		////(3)���ַ�������ת�����ַ���
		var valueHexOutput = valueHexArr2.join();
		////(4)ת����ԭ��������Ԫ���кܶࡰ,���������Ҫȥ������
		//// ִ���滻���������滻�ɿ�
		valueHexOutput = valueHexOutput.replace(/,/g, "");
		return valueHexOutput;
	}
}

//load the public message to html
function loadPublicPck(publicTableArr){
	var publicTableObj = getTargetControl(ethPublicPckTable);
	var publicRows = publicTableObj.getElementsByTagName('tr');
	for (var i = 1; i < publicRows.length; i++) {
		var inputTxt = filterTextChildNodes(publicRows[i].cells[2]);
		inputTxt.value = publicTableArr[i-1]; 
	}
}

//load the private message to html
function loadPrivatePck(privateTableArr){
	var privateTableObj = getTargetControl("ethPrivatePckTable");
	var privateTbodyObj = privateTableObj.getElementsByTagName("tbody")[0];
	for (var i = 0 ; i < parseInt(privateTableArr.length); i++) {
		addInstanceRow("ethPrivatePckTable");
		var optValue = parseInt(privateTableArr[i][0]);
		var optList = filterTextChildNodes(privateTbodyObj.rows[i+constOrgTrNum].cells[1]);
		optList[0].selected=false;
		optList[optValue].selected=true;
		var optTable = filterTextChildNodes(privateTbodyObj.rows[i+constOrgTrNum].cells[constOrgTdNum + optValue]);
		////�����ӱ���ÿһ�У���������ʽ����
		var optTrArr = optTable.getElementsByTagName('tr');
		////���������岿��
		for (var k = 1; k < optTrArr.length; k++) {
			//ȡ�����е�ԭʼ����
			var inputTxt = filterTextChildNodes(optTrArr[k].cells[1]);
			//set the value to jsonPrivateArr;
			inputTxt.value = privateTableArr[i][k]; 
		}
	}
}

//initial load function
function initLoad() {
	//set the cfg_path
	path=getPath("cfgFilePath");
	$.ajax({
		type: "POST", url: "/config",
		data: {
			"mode":0,
			"cfgPath":path[0],
			"filePath":"",
			"sim":"",
			"jsonPublic":"",
			"jsonPrivate":""
		} , 
		dataType: "json", success: function (message) { 
			// alert("get cfg path successful");
		 }, error: function (message) { 
			alert("get cfg path failed");
		}
	});
	//get the data from json file on the web server
	$.ajax({
		type: "GET", url: "/config",
		data: {
			json:$("#json").val()
		} , 
		dataType: "json", success: function (message) { 
			var publicTableArr = JSON.parse(message.message.ethPublicPckTable);
			loadPublicPck(publicTableArr);
			var privateTableArr = JSON.parse(message.message.ethPrivatePckTable);
			loadPrivatePck(privateTableArr);
			//alert("load successful\n"+JSON.stringify(message));
		 }, error: function (message) { 
			alert("load failed\n"+JSON.stringify(message));
		}
	});
}

//set the public pck
function setPublicPck(ethPublicPckTableId,contentArr,jsonPublicArr){
	////(Public Stream Write)
	var publicTableObj = getTargetControl(ethPublicPckTableId);
	var publicRows = publicTableObj.getElementsByTagName('tr');
	//alert(publicRows.length);
	contentArr[0] = "//===============================================================================================//";
	contentArr[1] = "//****";
	contentArr[2] = "//Public Stream Configuration ";
	contentArr[3] = contentArr[1];
	contentArr[4] = contentArr[0];
	contentArr[5] = "//Public Stream address";
	contentArr[6] = "@0000";
	var j = 7;
	for (var i = 1; i < publicRows.length; i++) {
		////(1)ȡ�����е�ԭʼ����
		contentArr[j] = publicRows[i].cells[1].innerHTML;
		////(2)��ȡ����������[\d+B]���֣�����[4B]����ȡ��4
		var re = /(\d+\s*B\s*\])/;
		var arr = re.exec(contentArr[j]);
		var numBytes = arr[1].replace(/B\]/g, "");
		////(3)���˵�ע�͡��ո���ı��ڵ�
		var inputTxt = filterTextChildNodes(publicRows[i].cells[2]);
		////(3.1)set the jsonPublicArr
		jsonPublicArr[i-1] = inputTxt.value;
		////(4)ȥ���ո�
		inputTxt.value = Trim(inputTxt.value);
		////(5)�ж��Ƿ���10������
		decimalCheck(contentArr[j], inputTxt.value);
		////(6)װ���µ�ע����Ϣ���������ֵ
		contentArr[j] = "//==" + contentArr[j] + " = " + inputTxt.value;
		////(7)ת����10����
		var decValue = parseInt(inputTxt.value);
		////(8)ת����16����
		var hexValue = decValue;
		hexValue = hexValue.toString(16);
		////(9)���ֽڸ�ʽ���ɳ�Ҫд����ַ���		
		var outputTxt = transformHexBytes(numBytes, hexValue);
		contentArr[j + 1] = outputTxt;
		j = j + 2;
	}
	return j;
}

//check the num stream
function checkNumStream(){
	if (numStream < 1) {
		alert("The numStream is less than 1,Error!!");
	}
}

// set the private pck
function setPrivatePck(ethPrivatePckTableId,contentArr,jsonPrivateArr,contentPt){
	////(Private Stream Write)
	var privateTableObj = getTargetControl(ethPrivatePckTableId);
	var privateTbodyObj = privateTableObj.getElementsByTagName("tbody")[0];
	var j = contentPt;
	for (var i = 0; i < parseInt(numStream); i++) {
		////initial jsonPrivateArr
		jsonPrivateArr[i] = new Array();
		////(1)���ɱ�ͷ��Ϣ
		//(1.1)Ѱ�ҵ�ǰ�����
		var numStreamCur = privateTbodyObj.rows[i+constOrgTrNum].cells[0].innerHTML;
		//(1.2)ȥ���ո�
		numStreamCur = Trim(numStreamCur);
		//(1.3)�������Ļ���ַ
		var numStreamDec = parseInt(numStreamCur);
		var numStreamAddr = numStreamDec * 1024;
		var hexAddr = numStreamAddr;
		hexAddr = hexAddr.toString(16);
		////(2)Ѱ�ҵ�����ѡ��ؼ�
		var selectNode = filterTextChildNodes(privateTbodyObj.rows[i+constOrgTrNum].cells[1]);
		var re = /\d+\s*\]/;
		var arr = re.exec(selectNode.value);
		////(2.1)Ѱ�ҵ�����ѡ��ؼ�������ֵ
		var optValue = arr[0].replace(/\]/g, "");
		// set the selectNode value
		jsonPrivateArr[i][0] = optValue;
		////(2.2)ͨ������ֵ���ҵ������ݶ�Ӧ���ӱ��
		var optTable = filterTextChildNodes(privateTbodyObj.rows[i+constOrgTrNum].cells[constOrgTdNum + parseInt(optValue)]);
		////(2.3)�����ӱ���ÿһ�У���������ʽ����
		var optTrArr = optTable.getElementsByTagName('tr');
		////(3)��ʼ��ÿ�����ı�ͷ
		contentArr[j + 0] = contentArr[0];
		contentArr[j + 1] = contentArr[1];
		contentArr[j + 2] = "//==NO." + numStreamCur + " Stream " + selectNode.value;
		contentArr[j + 3] = contentArr[1];
		contentArr[j + 4] = contentArr[0];
		contentArr[j + 5] = "//==Private Stream address";
		contentArr[j + 6] = "@" + hexAddr;//Stream Address
		//alert(contentArr[j+6]);
		j = j + 7;
		////(4)���������岿��
		for (var k = 1; k < optTrArr.length; k++) {
			//(4.1)ȡ�����е�ԭʼ����
			contentArr[j] = optTrArr[k].cells[0].innerHTML;
			//(4.2)��ȡ����������[\d+B]���֣�����[4B]����ȡ��4
			var re = /(\d+\s*B\s*\])/;
			var arr = re.exec(contentArr[j]);
			var numBytes = arr[1].replace(/B\]/g, "");
			//(4.3)���˵�ע�͡��ո���ı��ڵ�
			var inputTxt = filterTextChildNodes(optTrArr[k].cells[1]);
			//(4.3.1)set the value to jsonPrivateArr;
			jsonPrivateArr[i][k] = inputTxt.value; 
			//(4.4)ȥ���ո�;
			inputTxt.value = Trim(inputTxt.value);
			//(4.5)�ж��Ƿ��ǰ��ֽ���ʽ��16������������0x12f ��ʾ01 2f
			hexCheck("Stream No." + numStreamCur + contentArr[j], inputTxt.value, numBytes);
			//(4.6)װ���µ�ע����Ϣ���������ֵ
			contentArr[j] = "//==" + k + contentArr[j];
			//(4.7)ȥ������Ŀո�,������д
			contentArr[j] = contentArr[j].replace(/\s+/g, " ");
			//var numBytes=arr[1].replace(/B\]/g,"");
			var hexValue = inputTxt.value;
			//(4.8)װ������
			contentArr[j + 1] = hexValue;
			j += 2;
		}
	}
}

function getPath(cfgFilePathId){
	var filePathObj = getTargetControl(cfgFilePathId);
	var filePath = filePathObj.value;
	var cfgPath = filePath.replace(/SimEthStream.dat/g,"");
	return [cfgPath,filePath];
}

//send to web server
function sendToWebServer(cfgFilePathId,contentArr,jsonPublicArr,jsonPrivateArr){
	////(WriteFile from contentArr)
	//writeFile(filePath,contentArr); // No connect the web server 
	// Connect the web server
	var path = getPath(cfgFilePathId);
	var arrString=JSON.stringify(contentArr); 
	var jsonPublicString=JSON.stringify(jsonPublicArr);
	var jsonPrivateString=JSON.stringify(jsonPrivateArr);
	$.ajax({
		type: "POST", url: "/config",
		// contentType: "application/json;charset=utf-8", 
		data: {
			"mode":1,
			"cfgPath":path[0],
			"filePath":path[1],
			"sim":arrString,
			"jsonPublic":jsonPublicString,
			"jsonPrivate":jsonPrivateString
		} , 
		dataType: "json", success: function (message) { 
			alert("submit successful"+JSON.stringify(message));
		 }, error: function (message) { 
			alert("submit failed"+JSON.stringify(message));
		}
	});
}

//submit the result
function submitRun(cfgFilePathId, ethPublicPckTableId, ethPrivatePckTableId) {
	var contentArr = new Array();
	var jsonPublicArr = new Array();
	var jsonPrivateArr = new Array();
	var contentPt = setPublicPck(ethPublicPckTableId,contentArr,jsonPublicArr);
	checkNumStream();
	setPrivatePck(ethPrivatePckTableId,contentArr,jsonPrivateArr,contentPt);
	sendToWebServer(cfgFilePathId,contentArr,jsonPublicArr,jsonPrivateArr);
}

//check the decimal
function decimalCheck(strNote, strValue) {
	var re = /^\s*\d+\s*$/;
	if (re.test(strValue) != true) {
		alert("decimalCheck" + strNote + "Failed");
	}
}

//check the hex 
function hexCheck(strNote, strValue, numBytes) {
	//====(1) step delete the multi space 
	//==consider 1 "13    34"
	//==in order to calculate the length of the string.
	//==we should delete the multi space 
	//==so consider 1 "13    34" change to "13 34" 
	strValue = strValue.replace(/\s+/g, " ");
	//====(2) step
	//==consider 1 "12" 
	//==consider 2 "2f f5"
	//==the right side is no space,so add the space
	//==in order to easy to match the rule
	//==so consider 1 "1 12" change to "01 12 "
	//==so consider 2 "2f f5" change to "2f f5 "
	strValue += ' ';
	//====(3) step calculate the length of the string
	if (strValue.length != (numBytes * 3)) {
		alert("hexCheck" + strNote + strValue + "length error Failed");
	}
	//====(4) step check whether the pattern ok or not 
	//��{2}����ʾǰ��ı���飬���ܳ���2��
	//var re= /^\s*([a-fA-F0-9][a-fA-F0-9]\s+)+\s*$/;
	var re = /^\s*([a-fA-F0-9]{2}\s+)+\s*$/;
	if (re.test(strValue) != true) {
		alert("hexCheck" + strNote + strValue + "Failed");
	}
}

//������ʽ��ƥ�������ֵ
//matchKey�Ǳ�������ŵ�ֵ�Ǳ���inStrҪȥƥ���ֵ
//���inStr�ڲ�����matchKey��ֵ����ôƥ��ɹ���
//����1,���򷵻�0
function matchString(matchKey, inStr) {
	//����ñ���matchKey,����ʹ��new RegExp()�ķ�����
	//����������ַ���û���Ǹ���б�ܣ��������|�ķ���
	//re = new RegExp('(\\s|^)' + matchKey + '(\\s|$)');
	re = new RegExp(matchKey);
	return (re.test(inStr));
}

//show the table of td
function detailTdShow(tdObj, matchKey) {
	//���˵��ո�
	tdObj.style.color = Trim(tdObj.style.color);
	//(1)�ı���ɫ
	if (tdObj.style.color == 'blue') {
		tdObj.style.color = 'green';
	}
	else {
		tdObj.style.color = 'blue';
	}
	//(2)
	var parentTable = tdObj.parentNode.parentNode;

	var trArr = parentTable.getElementsByTagName('tr');

	for (var i = 1; i < trArr.length; i++) {
		if (matchString(matchKey, trArr[i].innerHTML) == true) {
			//==(1)ȥ����β�ո�
			//trArr[i].style.display=Trim(trArr[i].style.display);
			if (trArr[i].style.display == '')
				trArr[i].style.display = 'none';
			else
				trArr[i].style.display = '';
		}
	}
	tdObj.parentNode.style.display = '';
}

//update the config file path
function updateCfgFilePath(selfObj, cfgFilePathId) {
	var cfgObj = getTargetControl(cfgFilePathId);
	var cfgValue = cfgObj.value;
	cfgObj.value = cfgValue.replace(/tc\d+\w+\//, selfObj.value + '/');
	alert(cfgObj.value);
}

//д�뱾���ļ�
function writeFile(filePath, contentArr) {
	//var filePath = "test.dat";  
	//var stringContent = "Hell0";  
	try {
		netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
	} catch (e) {
		alert("no permisson...");
	}
	var file = Components.classes["@mozilla.org/file/local;1"].createInstance(Components.interfaces.nsILocalFile);
	file.initWithPath(filePath);
	if (file.exists() == false) {
		file.create(Components.interfaces.nsIFile.NORMAL_FILE_TYPE, 420);
	}
	var outputStream = Components.classes["@mozilla.org/network/file-output-stream;1"].createInstance(Components.interfaces.nsIFileOutputStream);
	outputStream.init(file, 0x04 | 0x08 | 0x20, 420, 0);
	var converter = Components.classes["@mozilla.org/intl/scriptableunicodeconverter"].createInstance(Components.interfaces.nsIScriptableUnicodeConverter);
	converter.charset = 'UTF-8';
	for (var i = 0; i < contentArr.length; i++) {
		var convSource = converter.ConvertFromUnicode(contentArr[i] + "\n");
		var result = outputStream.write(convSource, convSource.length);
	}
	outputStream.close();
	alert("File was saved in " + filePath);
}

//��ȡ�����ļ�  
function readFile(path) {
	try {
		netscape.security.PrivilegeManager.enablePrivilege("UniversalXPConnect");
	} catch (e) {
		alert("Permission to read file was denied.");
	}
	var file = Components.classes["@mozilla.org/file/local;1"]
		.createInstance(Components.interfaces.nsILocalFile);
	file.initWithPath(path);
	if (file.exists() == false) {
		alert("File does not exist");
	}
	var is = Components.classes["@mozilla.org/network/file-input-stream;1"]
		.createInstance(Components.interfaces.nsIFileInputStream);
	is.init(file, 0x01, 00004, null);
	var sis = Components.classes["@mozilla.org/scriptableinputstream;1"]
		.createInstance(Components.interfaces.nsIScriptableInputStream);
	sis.init(is);
	var converter = Components.classes["@mozilla.org/intl/scriptableunicodeconverter"]
		.createInstance(Components.interfaces.nsIScriptableUnicodeConverter);
	converter.charset = "UTF-8";
	var output = converter.ConvertToUnicode(sis.read(sis.available()));
	return output;
}
