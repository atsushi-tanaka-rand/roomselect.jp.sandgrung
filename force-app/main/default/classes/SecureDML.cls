/**
 * CRUD/FLSチェック用クラス
 */
public class SecureDML {
    public class SecureDMLException extends Exception {}
    
    /**
     * CRUD/FLSチェックを行うinsert
     * @param sObject[] records 登録対象オブジェクト
     * @param Boolean allOrNone 部分的処理完了フラグ（ture:許可しない、false:許可する）
     * @return Database.SaveResult[] 登録に成功したオブジェクト
     */
    public static Database.SaveResult[] secureInsert(sObject[] records, Boolean allOrNone) {
        return DataBase.insert(getSecureRecords(AccessType.CREATABLE, records), allOrNone);
    }
    
    /**
     * CRUD/FLSチェックを行うinsert
     */
    public static void secureInsert(sObject[] records) {
        insert getSecureRecords(AccessType.CREATABLE, records);
    }

    /**
     * CRUD/FLSチェックを行うinsert
     */
    public static void secureInsert(sObject record) {
        insert getSecureRecord(AccessType.CREATABLE, record);
    }

    /**
     * CRUD/FLSチェックを行うupdate
     */
    public static void secureUpdate(sObject[] records) {
        update getSecureRecords(AccessType.UPDATABLE, records);
    }

    /**
     * CRUD/FLSチェックを行うupdate
     */
    public static void secureUpdate(sObject record) {
        update getSecureRecord(AccessType.UPDATABLE, record);
    }

    /**
     * CRUD/FLSチェックを行うupsert
     */
    public static void secureUpsert(sObject[] records) {
        upsert getSecureRecords(AccessType.UPSERTABLE, records);
    }

    /**
     * CRUD/FLSチェックを行うupsert
     */
    public static void secureUpsert(sObject record) {
        upsert getSecureRecord(AccessType.UPSERTABLE, record);
    }
    
    /**
     * CRUD/FLSチェックを行うupsert
     */
    public static Database.UpsertResult[] secureUpsert(sObject[] records, Schema.SObjectField field) {
        return Database.upsert(getSecureRecords(AccessType.UPSERTABLE, records), field);
    }
        
    /**
     * CRUD/FLSチェックを行うupsert
     */
    public static Database.UpsertResult secureUpsert(sObject record, Schema.SObjectField field) {
        return Database.upsert(getSecureRecord(AccessType.UPSERTABLE, record), field);
    }
    
    /**
     * CRUDチェックを行うdelete
     */
    public static void secureDelete(sObject[] records) {
        if (records == null) throw new DMLException();
        if (records.isEmpty()) return;

        if (!records[0].getSObjectType().getDescribe().isDeletable()) {
            throw new SecureDMLException('オブジェクトのアクセス権限がありません。');
        }
        delete records;
    }

    /**
     * CRUDチェックを行うdelete
     */
    public static void secureDelete(sObject record) {
        if (record == null) throw new DMLException();
        secureDelete(new sObject[] {record});
    }

    /**
     * セキュアレコードを取得する
     * アクセス権がない場合にInvalidAccessExceptionを投げる。
     */
    public static sObject getSecureRecord(AccessType accessType, sObject record) {
        if (record == null) throw new DMLException();
        return getSecureRecords(accessType, new sObject[] {record})[0];
    }

    /**
     * セキュアレコードを取得する
     * アクセス権がない場合にInvalidAccessExceptionを投げる。
     */
    public static sObject[] getSecureRecords(AccessType accessType, sObject[] records) {
        if (records == null) throw new DMLException();
        if (records.isEmpty()) return records;

        SObjectAccessDecision decision;
        try {
            decision = Security.stripInaccessible(
                accessType,
                records
            );
        } catch(NoAccessException e) {
            // オブジェクトにアクセス権限がない場合の処理
            String objName = records[0].getSObjectType().getDescribe().getName();
            throw new SecureDMLException('オブジェクトのアクセス権限がありません。:' + objName, e);
        }
        
        // アクセスできない項目の対応付けを取得する
        Map<String, Set<String>> removedFields = decision.getRemovedFields();
        
        if (!removedFields.keySet().isEmpty()) {
            String[] removedFieldNames = new String[] {};
            Map<String, sObjectType> sObjTypeMap = Schema.getGlobalDescribe();
            for (String objName : removedFields.keySet()) {
                DescribesObjectResult obj = sObjTypeMap.get(objName).getDescribe();
                for (String fieldName : removedFields.get(objName)) {
                    // 子リレーションの場合は対象外チェックをしない
                    if (!fieldName.endsWith('__r')) {
                        DescribeFieldResult field = obj.fields.getMap().get(fieldName).getDescribe();
                        // 更新できない項目は権限チェック対象外とする
                        if(!field.isPermissionable() ||            // 権限を指定できない項目の場合
                           field.isAutoNumber() ||                 // 自動採番項目の場合
                           field.isCalculated() ||                 // 数式項目の場合
                           field.getType() == DisplayType.address  // 住所の場合
                          ){
                              continue;
                        }
                    }
                    removedFieldNames.add(objName + '.' + fieldName);
                }
            }
            // 権限チェック対象外のフィールドを除いてアクセス権限がない項目が一つでもある場合の処理
            if(!removedFieldNames.isEmpty()){
                throw new SecureDMLException('アクセス権限がない項目があります。:' + String.join(removedFieldNames, ','));
            }
        }
        // アクセス可能な項目のみのレコードを取得
        return records;
    }
}