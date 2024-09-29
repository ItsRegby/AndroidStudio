import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import kotlin.random.Random

class GreetingViewModel : ViewModel() {
    private val _text = MutableStateFlow("Hello, Compose, from Eduard)")
    val text: StateFlow<String> = _text

    fun changeText() {
        viewModelScope.launch {
            val randomText = listOf("Hello, World!", "Welcome to Compose!", "Button clicked!", "Random text here!").random()
            _text.value = randomText
        }
    }
}