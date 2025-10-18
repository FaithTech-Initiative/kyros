const admin = require('firebase-admin');
const fs = require('fs').promises;
const path = require('path');

// Initialize Firebase Admin SDK
const serviceAccount = require('./serviceAccountKey.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});
const db = admin.firestore();

async function uploadBibles() {
    try {
        const versionsDirectory = path.join(__dirname, '../assets/translations/EN-English');
        console.log(`Reading from directory: ${versionsDirectory}`);

        const files = await fs.readdir(versionsDirectory);
        const jsonFiles = files.filter(file => path.extname(file) === '.json');

        for (const file of jsonFiles) {
            const versionId = path.basename(file, '.json').toUpperCase();
            const filePath = path.join(versionsDirectory, file);

            try {
                const content = await fs.readFile(filePath, 'utf8');
                const jsonData = JSON.parse(content);

                // 1. Upload Version Metadata
                const versionDocRef = db.collection('versions').doc(versionId);
                await versionDocRef.set({
                    name: getVersionName(versionId),
                    language: 'en',
                    fileName: file,
                });
                console.log(`Uploaded metadata for ${versionId}`);

                // 2. Upload Bible Content (Book by Book)
                const bibleCollectionRef = db.collection('bibles').doc(versionId).collection('books');

                const books = jsonData.books;

                for (const bookData of books) {
                    const bookName = bookData.name;
                    const bookChapters = bookData.chapters;

                    const chaptersMap = {};
                    for (let i = 0; i < bookChapters.length; i++) {
                        const chapterNum = (i + 1).toString();
                        chaptersMap[chapterNum] = bookChapters[i];
                    }

                    await bibleCollectionRef.doc(bookName).set({ chapters: chaptersMap });
                    console.log(`  - Uploaded book: ${bookName}`);
                }

                console.log(`Successfully uploaded all books for version ${versionId}.`);
            } catch (e) {
                console.error(`Error processing file ${file}`, e);
            }
        }

        console.log('Bible upload process completed.');
    } catch (error) {
        console.error('Error uploading bibles:', error);
    }
}

function getVersionName(versionId) {
    // Simple mapping, can be extended
    const names = {
        'AKJV_BIBLE': 'American King James Version',
        'AMP_BIBLE': 'Amplified Bible',
        'ASV_BIBLE': 'American Standard Version',
        'BRG_BIBLE': 'BRG Bible',
        'CSB_BIBLE': 'Christian Standard Bible',
        'EHV_BIBLE': 'Evangelical Heritage Version',
        'ESVUK_BIBLE': 'English Standard Version Anglicised',
        'ESV_BIBLE': 'English Standard Version',
        'GNV_BIBLE': 'Geneva Bible',
        'GW_BIBLE': 'GOD\'S WORD Translation',
        'ISV_BIBLE': 'International Standard Version',
        'JUB_BIBLE': 'Jubilee Bible 2000',
        'KJ21_BIBLE': '21st Century King James Version',
        'KJV_BIBLE': 'King James Version',
        'LEB_BIBLE': 'Lexham English Bible',
        'MEV_BIBLE': 'Modern English Version',
        'NASB1995_BIBLE': 'New American Standard Bible 1995',
        'NASB_BIBLE': 'New American Standard Bible',
        'NET_BIBLE': 'New English Translation',
        'NIVUK_BIBLE': 'New International Version - UK',
        'NIV_BIBLE': 'New International Version',
        'NKJV_BIBLE': 'New King James Version',
        'NLT_BIBLE': 'New Living Translation',
        'NLV_BIBLE': 'New Life Version',
        'NOG_BIBLE': 'Names of God Bible',
        'NRSVUE_BIBLE': 'New Revised Standard Version Updated Edition',
        'NRSV_BIBLE': 'New Revised Standard Version',
        'WEB_BIBLE': 'World English Bible',
        'YLT_BIBLE': 'Young\'s Literal Translation'
    };
    return names[versionId] || versionId.replace('_BIBLE', '');
}

uploadBibles();