package com.newcmms.newcmms_flutter

import android.content.Intent
import android.nfc.NdefMessage
import android.nfc.NdefRecord
import android.nfc.cardemulation.HostApduService
import android.os.Binder
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import java.util.*



class NfcTextNdefHceService : HostApduService() {
    companion object {
        val TAG = NfcTextNdefHceService::class.java.name
        val NDEF_KEY = "ndefMessage"

        private val NFC_TAG_APP_SELECT_COMMAND = byteArrayOf(
                0x00.toByte(), // CLA	- Class - Class of instruction
                0xA4.toByte(), // INS	- Instruction - Instruction code
                0x04.toByte(), // P1	- Parameter 1 - Instruction parameter 1
                0x00.toByte(), // P2	- Parameter 2 - Instruction parameter 2
                0x07.toByte(), // Lc field	- Number of bytes present in the data field of the command
                0xD2.toByte(), 0x76.toByte(), 0x00.toByte(), 0x00.toByte(), 0x85.toByte(), 0x01.toByte(), 0x01.toByte(), // NDEF Tag Application name
                0x00.toByte()  // Le field	- Maximum number of bytes expected in the data field of the response to the command
        )

        private val CAPABILITY_CONTAINER_SELECT_COMMAND = byteArrayOf(
                0x00.toByte(), // CLA	- Class - Class of instruction
                0xa4.toByte(), // INS	- Instruction - Instruction code
                0x00.toByte(), // P1	- Parameter 1 - Instruction parameter 1
                0x0c.toByte(), // P2	- Parameter 2 - Instruction parameter 2
                0x02.toByte(), // Lc field	- Number of bytes present in the data field of the command
                0xe1.toByte(), 0x03.toByte() // file identifier of the CC file
        )

        private val CAPABILITY_CONTAINER_READ_FIRST_16_COMMAND = byteArrayOf(
                0x00.toByte(), // CLA	- Class - Class of instruction
                0xb0.toByte(), // INS	- Instruction - Instruction code
                0x00.toByte(), // P1	- Parameter 1 - Instruction parameter 1
                0x00.toByte(), // P2	- Parameter 2 - Instruction parameter 2
                0x0f.toByte()  // Lc field	- Number of bytes present in the data field of the command
        )

        private val CAPABILITY_CONTAINER_READ_RESPONSE = byteArrayOf(
                0x00.toByte(), 0x11.toByte(), // CCLEN length of the CC file
                0x20.toByte(), // Mapping Version 2.0
                0xFF.toByte(), 0xFF.toByte(), // MLe maximum
                0xFF.toByte(), 0xFF.toByte(), // MLc maximum
                0x04.toByte(), // T field of the NDEF File Control TLV
                0x06.toByte(), // L field of the NDEF File Control TLV
                0xE1.toByte(), 0x04.toByte(), // File Identifier of NDEF file
                0xFF.toByte(), 0xFE.toByte(), // Maximum NDEF file size of 65534 bytes
                0x00.toByte(), // Read access without any security
                0xFF.toByte(), // Write access without any security
                0x90.toByte(), 0x00.toByte() // A_OKAY
        )

        private val NDEF_SELECT_COMMAND = byteArrayOf(
                0x00.toByte(), // CLA	- Class - Class of instruction
                0xa4.toByte(), // Instruction byte (INS) for Select command
                0x00.toByte(), // Parameter byte (P1), select by identifier
                0x0c.toByte(), // Parameter byte (P1), select by identifier
                0x02.toByte(), // Lc field	- Number of bytes present in the data field of the command
                0xE1.toByte(), 0x04.toByte() // file identifier of the NDEF file retrieved from the CC file
        )

        private val NDEF_READ_BINARY_NLEN_COMMAND = byteArrayOf(
                0x00.toByte(), // Class byte (CLA)
                0xb0.toByte(), // Instruction byte (INS) for ReadBinary command
                0x00.toByte(), 0x00.toByte(), // Parameter byte (P1, P2), offset inside the CC file
                0x02.toByte()  // Le field
        )

        private val NDEF_READ_BINARY_COMMAND = byteArrayOf(
                0x00.toByte(), // Class byte (CLA)
                0xb0.toByte() // Instruction byte (INS) for ReadBinary command
        )

        private val OKAY_RESPONSE = byteArrayOf(
                0x90.toByte(), // SW1	Status byte 1 - Command processing status
                0x00.toByte()   // SW2	Status byte 2 - Command processing qualifier
        )

        private val ERROR_RESPONSE = byteArrayOf(
                0x6A.toByte(), // SW1	Status byte 1 - Command processing status
                0x82.toByte()   // SW2	Status byte 2 - Command processing qualifier
        )

        fun getNdefStringMessageBytes(value: String): ByteArray =
            NdefMessage(NdefRecord.createTextRecord("", "")).toByteArray()

        fun isValidStringMessage(bytes: ByteArray): Boolean = bytes.size in 5..0xfffe
    }

    private var _stringValue: String = ""
    private var _ndefBytes = NdefMessage(NdefRecord.createTextRecord("", "")).toByteArray()
    private var _hasSelectedNdef = false
    private val _binder: IBinder = NfcServiceBinder()

    var stringValue: String
        get() = _stringValue
        set(value) {
            val ndefBytes = getNdefStringMessageBytes(value)
            if (!isValidStringMessage(ndefBytes)) {
                throw IllegalArgumentException("Value must be valid NDEF message")
            }
            _stringValue = value
            _ndefBytes = ndefBytes
        }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.i(TAG, ::onStartCommand.name)
        return super.onStartCommand(intent, flags, startId)
    }

    override fun processCommandApdu(commandApdu: ByteArray?, extras: Bundle?): ByteArray {
        Log.i(TAG, "processCommandApdu() | incoming commandApdu: " + commandApdu?.toHex())

        if (Arrays.equals(commandApdu, NFC_TAG_APP_SELECT_COMMAND)) {
            Log.i(TAG, "NFC_TAG_APP_SELECT_COMMAND triggered. Our Response: " + OKAY_RESPONSE.toHex())
            return OKAY_RESPONSE
        }

        if (Arrays.equals(commandApdu, CAPABILITY_CONTAINER_SELECT_COMMAND)) {
            Log.i(TAG, "CAPABILITY_CONTAINER_SELECT_COMMAND triggered. Our Response: " + OKAY_RESPONSE.toHex())
            _hasSelectedNdef = false
            return OKAY_RESPONSE
        }

        if (Arrays.equals(commandApdu, CAPABILITY_CONTAINER_READ_FIRST_16_COMMAND) && !_hasSelectedNdef) {
            Log.i(TAG, "READ_CAPABILITY_CONTAINER triggered. Our Response: " + CAPABILITY_CONTAINER_READ_RESPONSE.toHex())
            return CAPABILITY_CONTAINER_READ_RESPONSE
        }

        if (Arrays.equals(commandApdu, NDEF_SELECT_COMMAND)) {
            Log.i(TAG, "NDEF_SELECT_COMMAND triggered. Our Response: " + OKAY_RESPONSE.toHex())
            _hasSelectedNdef = true
            return OKAY_RESPONSE
        }

        if (Arrays.equals(commandApdu, NDEF_READ_BINARY_NLEN_COMMAND)) {
            val sizeOfFile = _ndefBytes.size.toBigInteger().toByteArray().slice(0..1)
            val response = ByteArray(sizeOfFile.size + OKAY_RESPONSE.size)
            System.arraycopy(sizeOfFile, 0, response, 0, sizeOfFile.size)
            System.arraycopy(OKAY_RESPONSE, 0, response, sizeOfFile.size, OKAY_RESPONSE.size)
            Log.i(TAG, "NDEF_READ_BINARY_NLEN_COMMAND triggered. Our Response: " + response.toHex())
            return response
        }

        if (commandApdu != null && Arrays.equals(commandApdu.sliceArray(0..1), NDEF_READ_BINARY_COMMAND)) {
            val offset = commandApdu.sliceArray(2..3).toHex().toInt(16)
            val length = commandApdu.sliceArray(4..4).toHex().toInt(16)

            val response = ByteArray(length + OKAY_RESPONSE.size)
            System.arraycopy(_ndefBytes, offset, response, 0, length)
            System.arraycopy(_ndefBytes, 0, response, length, OKAY_RESPONSE.size)
            Log.i(TAG, "NDEF_READ_BINARY_COMMAND offset: $offset, length: $length, data: ${response.toHex()}")
            return response
        }

        Log.wtf(TAG, "processCommandApdu() | Unknown command ${commandApdu?.toHex()}")
        return ERROR_RESPONSE
    }

    override fun onDeactivated(reason: Int) {
        Log.i(TAG, "NFC HCE deactivated due to reason $reason")
    }

    inner class NfcServiceBinder : Binder() {
        fun getService(): NfcTextNdefHceService {
            return this@NfcTextNdefHceService
        }
    }
}

private val HEX_CHARS = "0123456789ABCDEF".toCharArray()

fun ByteArray.toHex() : String{
    val result = StringBuffer()

    forEach {
        val octet = it.toInt()
        val firstIndex = (octet and 0xF0).ushr(4)
        val secondIndex = octet and 0x0F
        result.append(HEX_CHARS[firstIndex])
        result.append(HEX_CHARS[secondIndex])
    }

    return result.toString()
}