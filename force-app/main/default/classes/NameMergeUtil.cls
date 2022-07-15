//名寄せ対象検索クラス
public class NameMergeUtil {

	//名寄せ対象検索メソッド
	public static List<Account> getCustomerMergeList(Account targetRecord, Id exceptionId) {
        
        // ▼問合せ350で追加
        String phone;
        String phone2;
        String phone3;

        if(targetRecord.Phone != null){
            phone = targetRecord.Phone.remove('-').remove('‐');
        }

        if(targetRecord.Phone2__c != null){
            phone2 = targetRecord.Phone2__c.remove('-').remove('‐');
        }

        if(targetRecord.Phone3__c != null){
            phone3 = targetRecord.Phone3__c.remove('-').remove('‐');
        }
        // ▲問合せ350で追加

		List<Account> accountResultList = [SELECT
										   Id, 
										   Name, 
										   NameKana__c, 
										   Address__c, 
										   Phone, 
										   Phone2__c, 
										   Phone3__c, 
										   Email__c, 
										   Email2__c, 
                                           Email3__c,
                                           // ポータルサイト構築 追加 Start
                                           (SELECT Id, Account__c, MemberId__c, Email__c  FROM MemberAccount__r),
                                           // ポータルサイト構築 追加 End
                                           // 追加要望 追加 Start
                                            (SELECT Id FROM IntroductionMailInformationAccount__r),
                                            // 追加要望 追加 End
											// ▼2021.10.08 No.307 対応で物件条件項目追加
											PropertyConditionsName__c,	//物件条件名
											(SELECT Name FROM AccountPropertyConditionss__r),	//お客様物件条件
											// ▲2021.10.08 No.307 対応で物件条件項目追加
                                           IsMergeUnnecessaryFlag__c, 
										   SystemModstamp
										   FROM Account
										   WHERE(id != :exceptionId)   //除外対象ではない
                                           AND(id != :targetRecord.Id) //名寄元ではない
                                           AND(RecordType.DeveloperName = :CommonConst.ACCOUNT_RECTYPE_CUSTOMER)//レコードタイプ指定 
                                           // 問合せ350で変更　取得条件をPhoneからPhoneWithoutHyphen__cに変更、電話番号のハイフンをremoveした値と比較
                                           AND(  (                      Name     = :targetRecord.Name 
                                                    AND (FirstName__c != null)
                                                    AND (LastName__c != null)  //2020.09.03 姓・名が空白のデータは名前の一致と判定しない
                                                 )
                                               OR(Email__c  != null AND Email__c = :targetRecord.Email__c) 
                                               OR(Email__c  != null AND Email__c = :targetRecord.Email2__c) 
                                               OR(Email__c  != null AND Email__c = :targetRecord.Email3__c) 
                                               OR(Email2__c != null AND Email2__c = :targetRecord.Email__c) 
                                               OR(Email2__c != null AND Email2__c = :targetRecord.Email2__c) 
                                               OR(Email2__c != null AND Email2__c = :targetRecord.Email3__c) 
                                               OR(Email3__c != null AND Email3__c = :targetRecord.Email__c) 
                                               OR(Email3__c != null AND Email3__c = :targetRecord.Email2__c) 
                                               OR(Email3__c != null AND Email3__c = :targetRecord.Email3__c) 

                                               OR(PhoneWithoutHyphen__c     != null AND PhoneWithoutHyphen__c in(:phone, :phone2, :phone3)) 
                                               OR(Phone2WithoutHyphen__c    != null AND Phone2WithoutHyphen__c in(:phone, :phone2, :phone3)) 
                                               OR(Phone3WithoutHyphen__c    != null AND Phone3WithoutHyphen__c in(:phone, :phone2, :phone3)) 

                                              )  
                                           ORDER BY Name ASC, NameKana__c ASC
                                          ];
		return accountResultList;

	}

	//業者名寄せ対象検索メソッド
	public static List<Account> getSupplierMergeList(Account targetRecord, Id exceptionId) {

		List<Account> accountResultList = [SELECT
										   id, 
										   Address__c, 
										   Phone, 
										   Email__c, 
										   PostalCode__c, 
										   Name, 
										   SupplierType__c, 
										   SystemModstamp
										   FROM Account
										   WHERE(id != :exceptionId) 
                                           AND(id != :targetRecord.Id) 
                                           AND(RecordType.DeveloperName = :CommonConst.ACCOUNT_RECTYPE_SUPPLIER)
                                           AND(  (name       != null AND name       = :targetRecord.Name)
                                               OR(Phone      != null AND Phone      = :targetRecord.Phone)
                                               OR(Address__c != null AND Address__c = :targetRecord.Address__C)
                                              )
                                           ORDER BY Name ASC
                                          ];


		return accountResultList;

	}

	

		//建物名寄せ対象検索メソッド
		public static List<Building__c> getBuildingMergeList(Building__c targetRecord, Id exceptionId) {

			List<Building__c> buildingResultList = [SELECT
											    Id, 
											    Name, 
											    BuildName2__c, 
											    BuildName3__c, 
											    BuildKana__c, 
											    BuildKana2__c, 
											    BuildKana3__c, 
											    PostalCode__c, 
											    Address__c, 
											    SystemModstamp
											    FROM Building__c
											    WHERE(id != :exceptionId) 
                                                    AND(id != :targetRecord.Id) 
                                                    AND(  (name          != null AND name          = :targetRecord.name         ) 
                                                        OR(name          != null AND name          = :targetRecord.BuildName2__c) 
                                                        OR(name          != null AND name          = :targetRecord.BuildName3__c) 
                                                        OR(BuildName2__c != null AND BuildName2__c = :targetRecord.name         ) 
                                                        OR(BuildName2__c != null AND BuildName2__c = :targetRecord.BuildName2__c) 
                                                        OR(BuildName2__c != null AND BuildName2__c = :targetRecord.BuildName3__c) 
                                                        OR(BuildName3__c != null AND BuildName3__c = :targetRecord.name         ) 
                                                        OR(BuildName3__c != null AND BuildName3__c = :targetRecord.BuildName2__c) 
                                                        OR(BuildName3__c != null AND BuildName3__c = :targetRecord.BuildName3__c) 
                                                        OR(BuildKana__c  != null AND BuildKana__c  = :targetRecord.BuildKana__c ) 
                                                        OR(BuildKana__c  != null AND BuildKana__c  = :targetRecord.BuildKana2__c) 
                                                        OR(BuildKana__c  != null AND BuildKana__c  = :targetRecord.BuildKana3__c) 
                                                        OR(BuildKana2__c != null AND BuildKana2__c = :targetRecord.BuildKana__c ) 
                                                        OR(BuildKana2__c != null AND BuildKana2__c = :targetRecord.BuildKana2__c) 
                                                        OR(BuildKana2__c != null AND BuildKana2__c = :targetRecord.BuildKana3__c) 
                                                        OR(BuildKana3__c != null AND BuildKana3__c = :targetRecord.BuildKana__c ) 
                                                        OR(BuildKana3__c != null AND BuildKana3__c = :targetRecord.BuildKana2__c) 
                                                        OR(BuildKana3__c != null AND BuildKana3__c = :targetRecord.BuildKana3__c) 
                                                        OR(Address__c    != null AND Address__c    = :targetRecord.Address__c   )
                                                       )
                                                    ORDER BY Name ASC, BuildKana__c ASC
                                                   ];

			return buildingResultList;

		}

    //物件名寄せ対象検索メソッド
    public static List<Property__c> getPropertyMergeList(Property__c targetRecord, Id exceptionId) {

        List<Property__c> propertyResultList = [
            SELECT
                Id
                ,Name
                ,SystemModstamp
            FROM
                Property__c
            WHERE
                Id          != :exceptionId
            AND Id          != :targetRecord.Id
            AND Name        =  :targetRecord.Name
            AND Building__c =  :targetRecord.Building__c
            ORDER BY
                Name
        ];

        return propertyResultList;

    }


    /**
     * 建物.名寄せ完了フラグ設定
     * @param  List<Building__c>    objs                    名寄せ対象
     * @return なし
     */
    public static void setBuildingMergeCompletedFlag(List<Building__c> objs) {
        NameMergeUtil.setBuildingMergeCompletedFlag(objs, false);
    }
    /**
     * 建物.名寄せ完了フラグ設定
     * @param  List<Building__c>    objs                    名寄せ対象
     * @param  Boolean              isMaintenancCode        自身の判定にメンテナンスコードを　True:含める / False:含めない
     * @return なし
     */
    public static void setBuildingMergeCompletedFlag(List<Building__c> objs, Boolean isMaintenancCode) {
        Boolean isMatch = false;
        List<Building__c> dbSearchList = new List<Building__c>();

        // ▼ 自身を検索
        for (Integer i = 0; i < objs.size(); i++) {
            isMatch =false;
            for (Integer j = 0; j < objs.size(); j++) {
                // 自分自身はスキップ
                if (i == j) {
                    continue;
                }

                // リスト内判定
                if(NameMergeUtil.isBuildingNameMearge(objs[i], objs[j], isMaintenancCode)) {
                    objs[i].IsMergeCompletedFlag__c = false;
                    isMatch = true;
                    break;
                }
            }

            // 自身に対象で無ければ、DB検索対象に追加
            if (!isMatch) {
                dbSearchList.add(objs[i]);
            }
        }
        // ▲ 自身を検索

        // ▼ DBを検索
        // IN 句作成
        List<String> nameIn    = new List<String>();
        List<String> kanaIn    = new List<String>();
        List<String> addressIn = new List<String>();
        for (Building__c obj : dbSearchList) {
            // 建物名
            if(obj.Name != null) {
                nameIn.add(obj.Name);
            }
            if (obj.BuildName2__c != null) {
                nameIn.add(obj.BuildName2__c);
            }
            if (obj.BuildName3__c != null) {
                nameIn.add(obj.BuildName3__c);
            }
            // 建物名カナ
            if (obj.BuildKana__c != null) {
                kanaIn.add(obj.BuildKana__c);
            }
            if (obj.BuildKana2__c != null) {
                kanaIn.add(obj.BuildKana2__c);
            }
            if (obj.BuildKana3__c != null) {
                kanaIn.add(obj.BuildKana3__c);
            }
            // 住所
            if (obj.State__c != null || obj.City__c != null || obj.Street__c != null) {
                String address = CommonConst.STRING_EMPTY;
                address += obj.State__c  != null ? obj.State__c  : CommonConst.STRING_EMPTY;
                address += obj.City__c   != null ? obj.City__c   : CommonConst.STRING_EMPTY;
                address += obj.Street__c != null ? obj.Street__c : CommonConst.STRING_EMPTY;
                addressIn.add(address);
            }
        }

        // データ取得
        List<Building__c> dbList = [SELECT Id
                                         , MaintenanceBuildingCode__c
                                         , Name
                                         , BuildName2__c
                                         , BuildName3__c
                                         , BuildKana__c
                                         , BuildKana2__c
                                         , BuildKana3__c
                                         , State__c
                                         , City__c
                                         , Street__c
                                      FROM Building__c
                                     WHERE (Name          != null AND Name          in :nameIn      )
                                        OR (BuildName2__c != null AND BuildName2__c in :nameIn      )
                                        OR (BuildName3__c != null AND BuildName3__c in :nameIn      )
                                        OR (BuildKana__c  != null AND BuildKana__c  in :kanaIn      )
                                        OR (BuildKana2__c != null AND BuildKana2__c in :kanaIn      )
                                        OR (BuildKana3__c != null AND BuildKana3__c in :kanaIn      )
                                        OR (Address__c    != null AND Address__c    in :addressIn   )
                                    ];

        for (Building__c obj1 :objs) {
            for (Building__c obj2 :dbList) {
                if (NameMergeUtil.isBuildingNameMearge(obj1, obj2, isMaintenancCode)) {
                    obj1.IsMergeCompletedFlag__c = false;
                    break;
                } 
            }
        }
        // ▲ DBを検索
    } 


    /**
     * 業者.名寄せ委完了フラグ設定
     * @param  List<Account>    objs                    名寄せ対象
     * @return なし
     */
    public static void setAccountMergeCompletedFlag(List<Account> objs) {
        NameMergeUtil.setAccountMergeCompletedFlag(objs, false);
    }
    /**
     * 業者.名寄せ完了フラグ設定
     * @param  List<Account>    objs                    名寄せ対象
     * @param  Boolean          isMaintenancCode        自身の判定にメンテナンスコードを　True:含める / False:含めない
     * @return なし
     */
    public static void setAccountMergeCompletedFlag(List<Account> objs, Boolean isMaintenancCode) {
        Boolean isMatch = false;
        List<Account> dbSearchList = new List<Account>();

        // ▼ 自身を検索
        for (Integer i = 0; i < objs.size(); i++) {
            isMatch =false;
            for (Integer j = 0; j < objs.size(); j++) {
                // 自分自身はスキップ
                if (i == j) {
                    continue;
                }

                // リスト内判定
                if(NameMergeUtil.isAccountNameMearge(objs[i], objs[j], isMaintenancCode)) {
                    objs[i].IsMergeCompletedFlag__c = false;
                    isMatch = true;
                    break;
                }
            }

            // 自身に対象で無ければ、DB検索対象に追加
            if (!isMatch) {
                dbSearchList.add(objs[i]);
            }
        }
        // ▲ 自身を検索

        // ▼ DBを検索
        // IN 句作成
        List<String> nameIn  = new List<String>();
        List<String> phoneIn = new List<String>();
        List<String> emailIn = new List<String>();
        for (Account obj : dbSearchList) {
            // 業者名
            if (obj.Name != null) {
                nameIn.add(obj.Name);
            }
            // 電話番号
            if (obj.Phone != null) {
                phoneIn.add(obj.Phone);
            }
            if (obj.Phone2__c != null) {
                phoneIn.add(obj.Phone2__c);
            }
            if (obj.Phone3__c != null) {
                phoneIn.add(obj.Phone3__c);
            }
            // Email
            if (obj.Email__c != null) {
                emailIn.add(obj.Email__c);
            }
            if (obj.Email2__c != null) {
                emailIn.add(obj.Email2__c);
            }
            if (obj.Email3__c != null) {
                emailIn.add(obj.Email3__c);
            }
        }
        // データ取得
        List<Account> dbList = [SELECT Id
                                     , RecordTypeId
                                     , MaintenanceSupplierCode__c
                                     , Name
                                     , Phone
                                     , Phone2__c
                                     , Phone3__c
                                     , Email__c
                                     , Email2__c
                                     , Email3__c
                                  FROM Account
                                 WHERE ((Name      != null) AND Name      in :nameIn)
                                    OR ((Phone     != null) AND Phone     in :phoneIn)
                                    OR ((Phone2__c != null) AND Phone2__c in :phoneIn)
                                    OR ((Phone3__c != null) AND Phone3__c in :phoneIn)
                                    OR ((Email__c  != null) AND Email__c  in :emailIn)
                                    OR ((Email2__c != null) AND Email2__c in :emailIn)
                                    OR ((Email3__c != null) AND Email3__c in :emailIn)
                                ];
        for (Account obj1 :objs) {
            for (Account obj2 :dbList) {
                if (NameMergeUtil.isAccountNameMearge(obj1, obj2, isMaintenancCode)) {
                    obj1.IsMergeCompletedFlag__c = false;
                    break;
                } 
            }
        }
        // ▲ DBを検索
    }



    /**
     * 物件名寄せ設定
     * @param  List<Property__c>    objs                    名寄せ対象
     * @return なし
     */
    public static void setPropertyMergeCompletedFlag(List<Property__c> objs) {
        NameMergeUtil.setPropertyMergeCompletedFlag(objs, false);
    }

    
    /**
     * 物件名寄せ設定
     * @param  List<Property__c>    objs                    名寄せ対象
     * @param  Boolean              isMaintenancCode        自身の判定にメンテナンスコードを　True:含める / False:含めない
     * @return なし
     */
    public static void setPropertyMergeCompletedFlag(List<Property__c> objs, Boolean isMaintenancCode) {
        Boolean isMatch = false;
        List<Property__c> dbSearchList = new List<Property__c>();

        // ▼ 自身を検索
        for (Integer i = 0; i < objs.size(); i++) {
            isMatch =false;
            for (Integer j = 0; j < objs.size(); j++) {
                // 自分自身はスキップ
                if (i == j) {
                    continue;
                }

                // リスト内判定
                if(isPropertyNameMerge(objs[i], objs[j], isMaintenancCode)) {
                    objs[i].IsMergeCompletedFlag__c = false;
                    isMatch = true;
                    break;
                }
            }

            // 自身に対象で無ければ、DB検索対象に追加
            if (!isMatch) {
                dbSearchList.add(objs[i]);
            }
        }
        // ▲ 自身を検索

        // ▼ DBを検索
        // IN 句作成
        List<Id> buildingIdIn  = new List<Id>();
        for (Property__c obj : dbSearchList) {
            if (obj.Building__c != null) {
                buildingIdIn.add(obj.Building__c);
            }
        }
        // データ取得
        List<Property__c> dbList = [SELECT Id
                                         , Name
                                         , Building__c
                                         , MaintenancePropertyCode__c
                                      FROM Property__c
                                     WHERE Building__c in :buildingIdIn
                                   ];
        for (Property__c obj1 :objs) {
            for (Property__c obj2 :dbList) {
                if (isPropertyNameMerge(obj1, obj2, isMaintenancCode)) {
                    obj1.IsMergeCompletedFlag__c = false;
                    break;
                } 
            }
        }
        // ▲ DBを検索
    }

    /**
     * 取引先名寄せ設定(登録時)
     * @param  List<Account>    名寄せ対象
     * @return なし
     */
	public static Void setCustomerMergeCompletedFlag(List<Account> objs) { 
        setCustomerMergeCompletedFlag(objs, new List<Id>());

    }

    /**
     * 取引先名寄せ設定(更新時)
     * @param  List<Account>    名寄せ対象
     * @param  List<Id>         自身のID
      *@return なし
     */
	public static Void setCustomerMergeCompletedFlag(List<Account> objs, List<Id> idList) { 
        system.debug('表示されてなければOK');
        List<String> nameList = new List<String>();
        List<String> mailList = new List<String>();
        List<String> phoneList = new List<String>();

        // ▼ 自身を検索
        for (Integer i = 0; i < objs.size(); i++) {
            // DB検索用にリストに格納
            nameList.add(objs[i].Name);
            if(objs[i].Email__c != null){
                mailList.add(objs[i].Email__c);
            }
            
            if(objs[i].Email2__c != null){
                mailList.add(objs[i].Email2__c);
            }
            
            if(objs[i].Email3__c != null){
                mailList.add(objs[i].Email3__c);
            }
            
            if(objs[i].Phone != null){
                phoneList.add(objs[i].Phone.remove('-').remove('‐'));
            }
            
            if(objs[i].Phone2__c != null){
                phoneList.add(objs[i].Phone2__c.remove('-').remove('‐'));
            }
            
            if(objs[i].Phone3__c != null){
                phoneList.add(objs[i].Phone3__c.remove('-').remove('‐'));
            }
            
            for (Integer j = 0; j < objs.size(); j++) {
                // 自分自身はスキップ
                if (i == j) {
                    continue;
                }

                // リスト内判定
                if (objs[i].Name == objs[j].Name &&
                    (isMatchMail(objs[i].Email__c,objs[j]) ||
                    isMatchMail(objs[i].Email2__c,objs[j]) || 
                    isMatchMail(objs[i].Email3__c,objs[j]) || 
                    isMatchPhone(objs[i].Phone,objs[j]) ||
                    isMatchPhone(objs[i].Phone2__c,objs[j]) ||
                    isMatchPhone(objs[i].Phone3__c,objs[j])) ) {
                        objs[i].IsMergeCompletedFlag__c = false;
                    	break;
                }
            }
        }
        // ▲ 自身を検索
        Id RECTYPEID_ACCOUNT_CUS = CommonUtil.getRecordTypeId('Account', 
                                        CommonConst.ACCOUNT_RECTYPE_CUSTOMER);

        // ▼ DBを検索
        // データ取得
        // 問合せ350で変更 取得項目にPhoneWithoutHyphen__c,Phone2WithoutHyphen__c,Phone3WithoutHyphen__c追加
        // 取得条件を Phone → PhoneWithoutHyphen__cに変更
        List<Account> dbList = [SELECT Id
                                     , Name
                                     , Phone
                                     , Phone2__c
                                     , Phone3__c
                                     , PhoneWithoutHyphen__c
                                     , Phone2WithoutHyphen__c
                                     , Phone3WithoutHyphen__c
                                     , Email__c
                                     , Email2__c
                                     , Email3__c
                                     , IsMergeUnnecessaryFlag__c
                                  FROM Account
                                 WHERE RecordTypeId = :RECTYPEID_ACCOUNT_CUS
                                    AND (((Name      != null) AND (FirstName__c != null) AND (LastName__c != null) //2020.09.03 姓・名が空白のデータは名前の一致と判定しない
                                            AND Name      in :nameList)
                                    OR PhoneWithoutHyphen__c     in :phoneList
                                    OR Phone2WithoutHyphen__c in :phoneList
                                    OR Phone3WithoutHyphen__c in :phoneList
                                    OR Email__c  in :mailList
                                    OR Email2__c in :mailList
                                    OR Email3__c in :mailList)
                                    AND Id NOT IN :idList
                                ];
system.debug('DBに名寄せ対象存在あり：' + dbList.size());
        for (Account obj :objs) {
            for (Account dt :dbList) {
                // リスト内判定
                if (obj.Name == dt.Name ||
                    (isMatchMail(obj.Email__c,dt) ||
                    isMatchMail(obj.Email2__c,dt) || 
                    isMatchMail(obj.Email3__c,dt) || 
                    isMatchPhone(obj.Phone,dt) ||
                    isMatchPhone(obj.Phone2__c,dt) ||
                    isMatchPhone(obj.Phone3__c,dt))) {
system.debug('一致！！');
                    obj.IsMergeCompletedFlag__c = false;
                    break;
                }
            }
        }
        // ▲ DBを検索

        // ▼ 2020.09.03 名寄せ対象データの更新　
        if (dbList.size() > 0){
            //名寄せ不要フラグを更新
            setCustomerMergeUnnecessaryFlag(dbList);
        }
        // ▲ 2020.09.03 名寄せ対象データの更新        
    }

    /**
     * 取引先メール一致確認
     * @param  String mail    一致確認するメール
     * @param  Account compareAccount    比較対象の取引先
     * @return Boolean
     */
	private static Boolean isMatchMail(String mail,Account compareAccount) {

        if(!String.isBlank(mail) &&
            (mail == compareAccount.Email__c ||
            mail == compareAccount.Email2__c ||
            mail == compareAccount.Email3__c)) {
                return true;        
        }  
        
        return false;    
    }

    /**
     * 取引先電話番号一致確認
     * @param  String phone    一致確認する電話
     * @param  Account compareAccount    比較対象の取引先
     * @return Boolean
     */
	private static Boolean isMatchPhone(String phone,Account compareAccount) {

        // 問合せ350で変更　phone → PhoneWithoutHyphen__c
        if(compareAccount != null) {
            String phone1;
            String phone2;
            String phone3;
            // 電話番号ハイフンなしがnullの場合、ハイフンをremoveした電話番号を使用
            if(compareAccount.Phone != null && compareAccount.PhoneWithoutHyphen__c == null) {
                phone1 = compareAccount.Phone.remove('-').remove('‐');
            } else {
                phone1 = compareAccount.PhoneWithoutHyphen__c;
            }
            if(compareAccount.Phone2__c != null && compareAccount.Phone2WithoutHyphen__c == null) {
                phone2 = compareAccount.Phone2__c.remove('-').remove('‐');
            } else {
                phone2 = compareAccount.Phone2WithoutHyphen__c;
            }
            if(compareAccount.Phone3__c != null && compareAccount.Phone3WithoutHyphen__c == null) {
                phone3 = compareAccount.Phone3__c.remove('-').remove('‐');
            } else {
                phone3 = compareAccount.Phone3WithoutHyphen__c;
            }
            if(!String.isBlank(phone) &&
                (phone.remove('-').remove('‐') == phone1 ||
                phone.remove('-').remove('‐') == phone2 ||
                phone.remove('-').remove('‐') == phone3)) {
                    return true;        
            }
        } 
        return false;    
    }

    
    /**
     * 取引先名寄せ不要フラグ設定
     * @param  List<Account>    名寄せで一致対象とされた取引先リスト
     * @return なし
     */
	public static Void setCustomerMergeUnnecessaryFlag(List<Account> objs) {

        List<Account> accList = new List<Account>();

        for (Account acc : objs) {
            //名寄せ不要フラグがtrueのものを、名寄せ不要フラグをfalseにしてリストに追加
            if (acc.IsMergeUnnecessaryFlag__c == true){
                accList.add(new Account(Id = acc.Id, IsMergeUnnecessaryFlag__c = false));
            }
        }

        //名寄せ不要フラグをfalseにして更新
        if (accList.size() > 0){
            SecureDML.secureUpdate(accList);
        }
    }

    /**
     * 建物の手動名寄せ対象判定
     * @param  Building__c  obj1                建物Obj
     * @param  Building__c  obj2                建物Obj
     * @param  Boolean      isMaintenancCode    メンテナンスコードを自身の判定に含める/含めない
     * @return Boolean      手動名寄せ判定
     */
    private static Boolean isBuildingNameMearge(Building__c obj1, Building__c obj2, Boolean isMaintenancCode) {
        // 自身であった場合、手動名寄せ対象外
        if (((obj1.Id != null || obj2.Id != null) && obj1.Id == obj2.Id) || (isMaintenancCode && obj1.MaintenanceBuildingCode__c == obj2.MaintenanceBuildingCode__c)) {
            return false;
        }

        // 名寄せ条件に一致した場合、Trueを返却
        Boolean isMatch = false;
        if (((obj1.Name          != null) && (obj1.Name          == obj2.Name         || obj1.Name          == obj2.BuildName2__c || obj1.Name          == obj2.BuildName3__c)) ||    // 建物名が１～３に一致
            ((obj1.BuildName2__c != null) && (obj1.BuildName2__c == obj2.Name         || obj1.BuildName2__c == obj2.BuildName2__c || obj1.BuildName2__c == obj2.BuildName3__c)) ||    // 建物名が１～３に一致
            ((obj1.BuildName3__c != null) && (obj1.BuildName3__c == obj2.Name         || obj1.BuildName3__c == obj2.BuildName2__c || obj1.BuildName3__c == obj2.BuildName3__c)) ||    // 建物名が１～３に一致
            ((obj1.BuildKana__c  != null) && (obj1.BuildKana__c  == obj2.BuildKana__c || obj1.BuildKana__c  == obj2.BuildKana2__c || obj1.BuildKana__c  == obj2.BuildKana3__c)) ||    // 建物名カナ１が1～３に一致
            ((obj1.BuildKana2__c != null) && (obj1.BuildKana2__c == obj2.BuildKana__c || obj1.BuildKana2__c == obj2.BuildKana2__c || obj1.BuildKana2__c == obj2.BuildKana3__c)) ||    // 建物名カナ２が1～３に一致
            ((obj1.BuildKana3__c != null) && (obj1.BuildKana3__c == obj2.BuildKana__c || obj1.BuildKana3__c == obj2.BuildKana2__c || obj1.BuildKana3__c == obj2.BuildKana3__c)) ||    // 建物名カナ３が1～３に一致        // 住所が一致
            ((obj1.State__c != null || obj1.City__c != null || obj1.Street__c != null) && (obj1.State__c == obj2.State__c && obj1.City__c == obj2.City__c && obj1.Street__c == obj2.Street__c))) {   // 住所が一致
            isMatch = true;
        }
        return isMatch;
    }

    /**
     * 業者名寄せ判定
     * @param  Account      obj1    取引先OBJ
     * @param  Account      obj2    取引先OBJ
     * @param  Boolean      isMaintenancCode    メンテナンスコードを自身の判定に含める/含めない
     * @return Boolean      手動名寄せ判定
     */
    private static Boolean isAccountNameMearge(Account obj1, Account obj2, Boolean isMaintenancCode) {
        // 業者ID, メンテナンスコード一致ならば自身である為、手動名寄せ対象外
        if (((obj1.Id != null || obj2.Id != null) && obj1.Id == obj2.Id) || (isMaintenancCode && obj1.MaintenanceSupplierCode__c == obj2.MaintenanceSupplierCode__c)) {
            return false;
        }

        // レコードタイプが異なる場合は、名寄せ対象外
        if (obj1.RecordtypeId != obj2.RecordtypeId) {
            return false;
        }

        // 手動名寄せ条件に一致した場合、Trueを返却
        Boolean isMatch = false;
        if (((obj1.Name       != null) &&  obj1.Name      == obj2.Name)    || 
            ((obj1.Phone      != null) && (obj1.Phone     == obj2.Phone    || obj1.Phone     == obj2.Phone2__c || obj1.Phone     == obj2.Phone3__c)) ||   // 電話番号が一致
            ((obj1.Phone2__c  != null) && (obj1.Phone2__c == obj2.Phone    || obj1.Phone2__c == obj2.Phone2__c || obj1.Phone2__c == obj2.Phone3__c)) ||   // 電話番号２が一致
            ((obj1.Phone3__c  != null) && (obj1.Phone3__c == obj2.Phone    || obj1.Phone3__c == obj2.Phone2__c || obj1.Phone3__c == obj2.Phone3__c)) ||   // 電話番号３が一致
            ((obj1.Email__c   != null) && (obj1.Email__c  == obj2.Email__c || obj1.Email__c  == obj2.Email2__c || obj1.Email__c  == obj2.Email3__c)) ||   // メールが一致
            ((obj1.Email2__c  != null) && (obj1.Email2__c == obj2.Email__c || obj1.Email2__c == obj2.Email2__c || obj1.Email2__c == obj2.Email3__c)) ||   // メール２が一致
            ((obj1.Email3__c  != null) && (obj1.Email3__c == obj2.Email__c || obj1.Email3__c == obj2.Email2__c || obj1.Email3__c == obj2.Email3__c))) {   // メール３が一致
            isMatch = true;
        }

        return isMatch;
    }

    /**
     * 物件名寄せ判定
     * @param   Property__c     obj1    物件oBJ
     * @param   Property__c     obj2    物件oBJ
     * @param   Boolean         isMaintenancCode    メンテナンスコードを自身の判定に含める/含めない
     * @return  Boolean         手動名寄せ判定
     */
    private static Boolean isPropertyNameMerge(Property__c obj1, Property__c obj2, Boolean isMaintenancCode) {
        // 自身であった場合、名寄せ対象外
        if (((obj1.Id != null || obj2.Id != null) && obj1.Id == obj2.Id) || (isMaintenancCode && obj1.MaintenancePropertyCode__c == obj2.MaintenancePropertyCode__c)) {
            return false;
        }


        // 手動名寄せ条件に一致した場合、Trueを返却
        Boolean isMatch = false;
        if (obj1.Building__c == obj2.Building__c && obj1.Name == obj2.Name) {
            isMatch = true;
        }
        return isMatch;
    }
}